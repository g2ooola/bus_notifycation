# INIT
  # read subscript data

  # trans `input` to `subscript-data-object`
  [{
    target: {
      station_name: 'xxx',
      bus_way: '去/回',
      bus_line: '672',
      started_at: '17:00',
      ended_at: '18:00',
    },
    subscriber: {
      email: '',
      phone: ''
    }
  }]

# API
  # trans `subscript-data-object` to `api-target-data-object`
  [
    station_id_1, station_id_2
  ]

  [{
    target: {
      station_id: 1,
      started_at_int_delta: 61200,
      ended_at_int_delta: 64800
    },
    subscribers: [{
      email: '',
      phone: ''
    }]
  }]

  # get bus data

  # trans `api-return` to `realtime-data-object`

# NOTIFY
  # check notify hite by `subscript-data-object`, `realtime-data-object`

  # send notify