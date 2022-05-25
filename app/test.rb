require_relative './bus_infos/pda/realtime_bus_of_station_source.rb'
require_relative './bus_infos/pda/subscribtion_data_normalizer.rb'
require_relative './bus_infos/pda/handler.rb'
require_relative './subscribtions/file_reader.rb'
require_relative './notifiers/handler.rb'
require_relative './notifiers/email_notification.rb'
require_relative './toolkits/secret.rb'
require_relative './toolkits/default_log.rb'

require 'yaml'


def test_notify_too_close
  subscribed_record = {
    target: {
      bus_no: 'name',
      station_name: 'xxx',
      station_id: 1,
      started_at_int_delta: 61200,
      ended_at_int_delta: 64800
    },
    subscribers: {
      notified_at: Time.now.getlocal('+08:00').to_s,
      all_contact_way: [{
        email: '',
        phone: ''
      }]
    }
  }

  notifier = Notifiers::Handler.new
  notifier.notify_if_need(
    bus_arrive_sec: 300,
    subscribe_record: subscribed_record
  )

  # should log `notify_too_close`
end

def test_notify_time_too_long
  subscribed_record = {
    target: {
      bus_no: 'name',
      station_name: 'xxx',
      station_id: 1,
      started_at_int_delta: 61200,
      ended_at_int_delta: 64800
    },
    subscribers: {
      notified_at: nil,
      all_contact_way: [{
        email: '',
        phone: ''
      }]
    }
  }

  notifier = Notifiers::Handler.new
  notifier.notify_if_need(
    bus_arrive_sec: 1000,
    subscribe_record: subscribed_record
  )

  # should log `time_too_long`
end

def test_notify_arrived_to_all
  subscribed_record = {
    target: {
      bus_no: 'name',
      station_name: 'xxx',
      station_id: 1,
      started_at_int_delta: 61200,
      ended_at_int_delta: 64800
    },
    subscribers: {
      notified_at: nil,
      all_contact_way: [{
        email: 'someone@email.com',
        phone: ''
      }]
    }
  }

  notifier = Notifiers::Handler.new
  notifier.notify_if_need(
    bus_arrive_sec: 300,
    subscribe_record: subscribed_record
  )

  # should log `time_too_long`
end

def test_notify_calcel_to_all
  subscribed_record = {
    target: {
      bus_no: 'name',
      station_name: 'xxx',
      station_id: 1,
      started_at_int_delta: 61200,
      ended_at_int_delta: 64800
    },
    subscribers: {
      notified_at: nil,
      all_contact_way: [{
        email: 'someone@email.com',
        phone: ''
      }]
    }
  }

  notifier = Notifiers::Handler.new
  notifier.notify_if_need(
    bus_arrive_sec: -1,
    subscribe_record: subscribed_record
  )

  # should log `time_too_long`
end

def test_default_log
  Toolkits::DefaultLog.logger.info('123')
end

def test_yml
  puts Toolkits::Secret.info
end

def test_api_pda
  info_source = BusInfos::Pda::RealtimeBusOfStationSource.new
  result = info_source.get_from_api(38878)
  puts result
end

def test_email_notification
  email_notification = Notifiers::EmailNotifycation.new
  email_notification.notify_bus_will_be_arrived(
    email: 'gsx1415@gmail.com',
    bus: '672',
    station_name: '台電大樓',
    arrive_minutes: 7
  )
end

def test_file_reader
  subscribed_source = Subscribtions::FileReader.new
  subscribed_records = subscribed_source.read!
  subscribed_records.each do |record|
    puts record.to_a.join(',')
  end; nil
end

def test_pda_sub_normalize
  object = BusInfos::Pda::SubscribtionDataNormalizer.new
  output = object.exec([
    {'email'=>'e1@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'},
    {'email'=>'e2@email.com','bus_no'=>'棕1','direction'=>'回程','station_name'=>'公教住宅'},
    {'email'=>'e3@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'}
  ])

  should_be = {"38873"=>[{:email=>"e1@email.com"}, {:email=>"e3@email.com"}], "13365"=>[{:email=>"e2@email.com"}]}
  
  result = output == should_be
  puts result
  result
end

def test_pda_sub_station_id_map
  object = BusInfos::Pda::SubscribtionDataNormalizer.new
  output = object.send(:station_id_map, 10291)

  should_be = {"去程"=>{"潭美國小(行善)"=>"181399", "潭美國小(舊宗)"=>"57291", "週美里一"=>"13315", "玉成里"=>"13317", "松山車站(八德)"=>"13319", "松山農會"=>"13321", "饒河街觀光夜市(塔悠)"=>"13323", "南松山(塔悠)"=>"13325", "發電所(西松高中)"=>"13327", "新東里"=>"13329", "新東街口"=>"13331", "民生社區活動中心"=>"13333", "聯合二村"=>"13335", "介壽國中"=>"13337", "公教住宅"=>"13339", "民生敦化路口"=>"13341", "民生復興路口"=>"13343", "民生東路口"=>"13345", "捷運中山國中站"=>"13347", "民權敦化路口"=>"13349", "松山機場"=>"57293"}, "回程"=>{"民權敦化路口"=>"13355", "民權復興路口"=>"13357", "捷運中山國中站"=>"13359", "民生復興路口"=>"13361", "民生敦化路口"=>"13363", "公教住宅"=>"13365", "介壽國中"=>"13367", "聯合二村"=>"13369", "民生社區活動中心"=>"13371", "新東街口"=>"13373", "新東里"=>"13375", "發電所(西松高中)"=>"13377", "南松山(塔悠)"=>"13379", "饒河街觀光夜市(塔悠)"=>"13381", "松山農會"=>"13383", "松山車站(八德)"=>"13385", "玉成里"=>"13387", "週美里一"=>"13389", "潭美國小(舊宗)"=>"57292", "潭美國小(行善)"=>"181400"}}

  result = output == should_be
  puts result
  result
end

def test_pda_handler
  object = BusInfos::Pda::Handler.new
  output_1 = object.normalizer([
    {'email'=>'e1@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'},
    {'email'=>'e2@email.com','bus_no'=>'棕1','direction'=>'回程','station_name'=>'公教住宅'},
    {'email'=>'e3@email.com','bus_no'=>'672','direction'=>'去程','station_name'=>'秀朗國小'}
  ])
  should_be_1 = {"38873"=>[{:email=>"e1@email.com"}, {:email=>"e3@email.com"}], "13365"=>[{:email=>"e2@email.com"}]}
  result_1 = output_1 == should_be_1

  output_2 = object.realtime_bus_info_of_station(38873)
  result_2 = output_2.is_a? Integer

  result = result_1 && result_2
  puts result
  result
end

test_pda_handler