require_relative './bus_infos/pda/realtime_bus_of_station_source.rb'
require_relative './bus_infos/pda/subscribtion_data_normalizer.rb'
require_relative './bus_infos/pda/handler.rb'
require_relative './subscribtions/file_reader.rb'
require_relative './notifiers/handler.rb'
require_relative './notifiers/email_notification.rb'
require_relative './toolkits/secret.rb'
require_relative './toolkits/helper.rb'

require 'yaml'

class TestMachine
  # bus 將在一秒後抵達, 應該要觸發通知
  BUS_ARRIVE_SEC_TO_NOTIFY = 1

  # 未加入 test_all
  def start_test_yml
    puts Toolkits::Secret.info
  end

  # 未加入 test_all
  def start_test_email_notification
    email_notification = Notifiers::EmailNotifycation.new
    email_notification.notify_bus_will_be_arrived(
      email: 'someone@email.com',
      bus: '672',
      station_name: '台電大樓',
      arrive_minutes: 7
    )
  end

  def test_notify_too_close
    subscribtion_data = {
      target: {
        bus_no: 'name',
        direction: '去程',
        station_name: 'xxx',
        station_id: 1
      },
      notified_at: Toolkits::Helper.time_to_string(Time.now - 1),
      subscribers: [{
        email: '',
        phone: ''
      }]
    }

    notifier = Notifiers::Handler.new
    output = notifier.notify_if_need(
      bus_arrive_sec: BUS_ARRIVE_SEC_TO_NOTIFY,
      subscribtion_data: subscribtion_data
    )

    should_be = 'notify_too_close'

    output == should_be
  end

  def test_notify_time_too_long
    subscribtion_data = {
      target: {
        bus_no: 'name',
        direction: '去程',
        station_name: 'xxx',
        station_id: 1
      },
      notified_at: nil,
      subscribers: [{
        email: '',
        phone: ''
      }]
    }

    notifier = Notifiers::Handler.new
    output = notifier.notify_if_need(
      bus_arrive_sec: 1000,
      subscribtion_data: subscribtion_data
    )

    should_be = 'time_too_long 1000'

    output == should_be
  end

  def test_notify_arrived_to_all
    subscribtion_data = {
      target: {
        bus_no: 'name',
        direction: '去程',
        station_name: 'xxx',
        station_id: 1
      },
      notified_at: nil,
      subscribers: [{
        email: 'someone@email.com',
        phone: ''
      }]
    }

    notifier = Notifiers::Handler.new
    output = notifier.notify_if_need(
      bus_arrive_sec: BUS_ARRIVE_SEC_TO_NOTIFY,
      subscribtion_data: subscribtion_data
    )

    should_be = ['notify_bus_will_be_arrived']

    output == should_be
  end

  def test_notify_calcel_to_all
    subscribtion_data = {
      target: {
        bus_no: 'name',
        direction: '去程',
        station_name: 'xxx',
        station_id: 1
      },
      notified_at: nil,
      subscribers: [{
        email: 'someone@email.com',
        phone: ''
      }]
    }

    notifier = Notifiers::Handler.new
    output = notifier.notify_if_need(
      bus_arrive_sec: -1,
      subscribtion_data: subscribtion_data
    )

    should_be = ['notify_special_state']

    output == should_be
  end

  def test_api_pda
    info_source = BusInfos::Pda::RealtimeBusOfStationSource.new
    output = info_source.get_from_api(38878)

    output.is_a? Integer
  end

  def test_file_reader
    subscribed_source = Subscribtions::FileReader.new
    subscribed_records = subscribed_source.read!

    should_be = [
      { 'email' => 'e1@email.com', 'bus_no' => '672', 'direction' => '去程', 'station_name' => '秀朗國小' },
      { 'email' => 'e2@email.com', 'bus_no' => '棕1', 'direction' => '回程', 'station_name' => '公教住宅' },
      { 'email' => 'e3@email.com', 'bus_no' => '672', 'direction' => '去程', 'station_name' => '秀朗國小' }
    ]
    result_not_eq = 0
    should_be.each_with_index do |record_should_be, index|
      record_should_be.each do |key, value|
        result_not_eq += 1 if subscribed_records[index][key] != value
      end
    end

    result_not_eq == 0
  end

  def test_pda_sub_normalize
    object = BusInfos::Pda::SubscribtionDataNormalizer.new
    output = object.exec([
      {'email'=>'e1@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'},
      {'email'=>'e2@email.com','bus_no'=>'棕1','direction'=>'回程','station_name'=>'公教住宅'},
      {'email'=>'e3@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'}
    ])

    should_be = {
      "38873"=>{
        target: { bus_no: '672', direction: '去程', station_name: '秀朗國小', station_id: '38873'},
        subscribers: [{:email=>"e1@email.com"}, {:email=>"e3@email.com"}]
      },
      "13365"=>{
        target: { bus_no: '棕1', direction: '回程', station_name: '公教住宅', station_id: '13365'},
        subscribers: [{:email=>"e2@email.com"}]
      }
    }
    
    output == should_be
  end

  def test_pda_sub_bus_id_map
    object = BusInfos::Pda::SubscribtionDataNormalizer.new
    output = object.send(:bus_id_map)

    result = output['紅2'] == '15312' && output['藍46'] == '16586' && output['672'] == '10785'
  end

  def test_pda_sub_station_id_map
    object = BusInfos::Pda::SubscribtionDataNormalizer.new
    output = object.send(:station_id_map, 10291)

    should_be = {"去程"=>{"潭美國小(行善)"=>"181399", "潭美國小(舊宗)"=>"57291", "週美里一"=>"13315", "玉成里"=>"13317", "松山車站(八德)"=>"13319", "松山農會"=>"13321", "饒河街觀光夜市(塔悠)"=>"13323", "南松山(塔悠)"=>"13325", "發電所(西松高中)"=>"13327", "新東里"=>"13329", "新東街口"=>"13331", "民生社區活動中心"=>"13333", "聯合二村"=>"13335", "介壽國中"=>"13337", "公教住宅"=>"13339", "民生敦化路口"=>"13341", "民生復興路口"=>"13343", "民生東路口"=>"13345", "捷運中山國中站"=>"13347", "民權敦化路口"=>"13349", "松山機場"=>"57293"}, "回程"=>{"民權敦化路口"=>"13355", "民權復興路口"=>"13357", "捷運中山國中站"=>"13359", "民生復興路口"=>"13361", "民生敦化路口"=>"13363", "公教住宅"=>"13365", "介壽國中"=>"13367", "聯合二村"=>"13369", "民生社區活動中心"=>"13371", "新東街口"=>"13373", "新東里"=>"13375", "發電所(西松高中)"=>"13377", "南松山(塔悠)"=>"13379", "饒河街觀光夜市(塔悠)"=>"13381", "松山農會"=>"13383", "松山車站(八德)"=>"13385", "玉成里"=>"13387", "週美里一"=>"13389", "潭美國小(舊宗)"=>"57292", "潭美國小(行善)"=>"181400"}}

    output == should_be
  end

  def test_pda_handler
    object = BusInfos::Pda::Handler.new
    output_1 = object.normalize([
      {'email'=>'e1@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'},
      {'email'=>'e2@email.com','bus_no'=>'棕1','direction'=>'回程','station_name'=>'公教住宅'},
      {'email'=>'e3@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'}
    ])
    should_be_1 = {
      "38873"=>{
        target: { bus_no: '672', direction: '去程', station_name: '秀朗國小', station_id: '38873'},
        subscribers: [{:email=>"e1@email.com"}, {:email=>"e3@email.com"}]
      },
      "13365"=>{
        target: { bus_no: '棕1', direction: '回程', station_name: '公教住宅', station_id: '13365'},
        subscribers: [{:email=>"e2@email.com"}]
      }
    }
    result_1 = output_1 == should_be_1

    output_2 = object.realtime_bus_info_of_station(38873)
    result_2 = output_2.is_a? Integer

    result_1 && result_2
  end
end

def test_all
  all_methods = [
    :test_notify_too_close,
    :test_notify_time_too_long,
    :test_notify_arrived_to_all,
    :test_notify_calcel_to_all,
    :test_api_pda,
    :test_file_reader,
    :test_pda_sub_normalize,
    :test_pda_sub_station_id_map,
    :test_pda_handler,
  ]

  fail_count = 0
  test_machine = TestMachine.new
  all_methods.each do |method_name|
    begin
      success = test_machine.send(method_name)
    rescue => e
      # do nothing
    end

    unless success
      puts "fail! #{method_name}" 
      fail_count += 1
    end
  end
  puts " == finish, fail_count: #{fail_count} =="
end

def test_one(method_name)
  success = TestMachine.new.send(method_name)
  puts "test #{method_name} #{success}"
end

test_all()
# test_one(:test_email_notification)
