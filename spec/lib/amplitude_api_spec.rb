require 'spec_helper'

describe AmplitudeAPI do
  let(:user) { Struct.new(:id).new(123) }
  let(:device_id) { 'abcdef' }

  before do
    @described_class_instance = described_class.new('stub api key')
  end

  describe '.track' do
    context 'with a single event' do
      context 'with only user_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            event_type: 'clicked on sign up'
          )
          body = {
            api_key: @described_class_instance.api_key,
            event: JSON.generate([event.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

          @described_class_instance.track(event)
        end
      end
      context 'with only device_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            device_id: device_id,
            event_type: 'clicked on sign up'
          )
          body = {
            api_key: @described_class_instance.api_key,
            event: JSON.generate([event.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

          @described_class_instance.track(event)
        end
      end
      context 'with both user_id and device_id' do
        it 'sends the event to Amplitude' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            device_id: device_id,
            event_type: 'clicked on sign up'
          )
          body = {
            api_key: @described_class_instance.api_key,
            event: JSON.generate([event.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

          @described_class_instance.track(event)
        end
      end
    end

    context 'with multiple events' do
      it 'sends all events in a single request' do
        event = AmplitudeAPI::Event.new(
          user_id: 123,
          event_type: 'clicked on sign up'
        )
        event2 = AmplitudeAPI::Event.new(
          user_id: 456,
          event_type: 'liked a widget'
        )
        body = {
          api_key: @described_class_instance.api_key,
          event: JSON.generate([event.to_hash, event2.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::TRACK_URI_STRING, body: body)

        @described_class_instance.track([event, event2])
      end
    end
  end

  describe '.identify' do
    context 'with a single identification' do
      context 'with only user_id' do
        it 'sends the identification to Amplitude' do
          identification = AmplitudeAPI::Identification.new(
            user_id: 123,
            user_properties: {
              first_name: 'John',
              last_name: 'Doe'
            }
          )
          body = {
            api_key: @described_class_instance.api_key,
            identification: JSON.generate([identification.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

          @described_class_instance.identify(identification)
        end
      end
      context 'with only device_id' do
        it 'sends the identification to Amplitude' do
          identification = AmplitudeAPI::Identification.new(
            device_id: device_id,
            user_properties: {
              first_name: 'John',
              last_name: 'Doe'
            }
          )
          body = {
            api_key: @described_class_instance.api_key,
            identification: JSON.generate([identification.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

          @described_class_instance.identify(identification)
        end
      end
      context 'with both user_id and device_id' do
        it 'sends the identification to Amplitude' do
          identification = AmplitudeAPI::Identification.new(
            user_id: 123,
            device_id: device_id,
            user_properties: {
              first_name: 'John',
              last_name: 'Doe'
            }
          )
          body = {
            api_key: @described_class_instance.api_key,
            identification: JSON.generate([identification.to_hash])
          }

          expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

          @described_class_instance.identify(identification)
        end
      end
    end

    context 'with multiple identifications' do
      it 'sends all identifications in a single request' do
        identification = AmplitudeAPI::Identification.new(
          user_id: 123,
          user_properties: {
            first_name: 'Julian',
            last_name: 'Ponce'
          }
        )
        identification2 = AmplitudeAPI::Identification.new(
          device_id: 456,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        body = {
          api_key: @described_class_instance.api_key,
          identification: JSON.generate([identification.to_hash, identification2.to_hash])
        }

        expect(Typhoeus).to receive(:post).with(AmplitudeAPI::IDENTIFY_URI_STRING, body: body)

        @described_class_instance.identify([identification, identification2])
      end
    end
  end

  describe '.initializer ' do
    it 'initializes event without parameter' do
      event = AmplitudeAPI::Event.new
      expect(event.to_hash).to eq(
        event_type: '',
        user_id: '',
        event_properties: {},
        user_properties: {},
        ip: ''
      )
    end

    it 'initializes event with parameter' do
      event = AmplitudeAPI::Event.new(
        user_id: 123,
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        },
        ip: '8.8.8.8'
      )
      expect(event.to_hash).to eq(
        event_type: 'test_event',
        user_id: 123,
        event_properties: { test_property: 1 },
        user_properties: {},
        ip: '8.8.8.8'
      )
    end
    it 'initializes event with parameter including device_id' do
      event = AmplitudeAPI::Event.new(
        user_id: 123,
        device_id: 'abc',
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        },
        ip: '8.8.8.8'
      )
      expect(event.to_hash).to eq(
        event_type: 'test_event',
        user_id: 123,
        device_id: 'abc',
        event_properties: { test_property: 1 },
        user_properties: {},
        ip: '8.8.8.8'
      )
    end
  end

  describe '.send_event' do
    context 'with only user_id' do
      it 'sends an event to AmplitudeAPI' do
        event = AmplitudeAPI::Event.new(
          user_id: user,
          event_type: 'test_event',
          event_properties: { test_property: 1 }
        )
        expect(@described_class_instance).to receive(:track).with(event)

        @described_class_instance.send_event('test_event', user, nil, event_properties: { test_property: 1 })
      end

      context 'the user is nil' do
        it 'sends an event with the no account user' do
          event = AmplitudeAPI::Event.new(
            user_id: nil,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(@described_class_instance).to receive(:track).with(event)

          @described_class_instance.send_event('test_event', nil, nil, event_properties: { test_property: 1 })
        end
      end

      context 'the user is a user_id' do
        it 'sends an event to AmplitudeAPI' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(@described_class_instance).to receive(:track).with(event)

          @described_class_instance.send_event('test_event', user.id, nil, event_properties: { test_property: 1 })
        end

        it 'sends arbitrary user_properties to AmplitudeAPI' do
          event = AmplitudeAPI::Event.new(
            user_id: 123,
            event_type: 'test_event',
            event_properties: { test_property: 1 },
            user_properties: { test_user_property: 'abc' }
          )
          expect(@described_class_instance).to receive(:track).with(event)

          @described_class_instance.send_event(
            'test_event',
            user.id,
            nil,
            event_properties: { test_property: 1 },
            user_properties: { test_user_property: 'abc' }
          )
        end
      end
    end
    context 'with device_id' do
      context 'the user is not nil' do
        it 'sends an event to AmplitudeAPI' do
          event = AmplitudeAPI::Event.new(
            user_id: user,
            device_id: device_id,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(@described_class_instance).to receive(:track).with(event)

          @described_class_instance.send_event('test_event', user, device_id, event_properties: { test_property: 1 })
        end
      end

      context 'the user is nil' do
        it 'sends an event with the no account user' do
          event = AmplitudeAPI::Event.new(
            user_id: nil,
            device_id: device_id,
            event_type: 'test_event',
            event_properties: { test_property: 1 }
          )
          expect(@described_class_instance).to receive(:track).with(event)

          @described_class_instance.send_event('test_event', nil, device_id, event_properties: { test_property: 1 })
        end
      end
    end
  end

  describe '.send_identify' do
    context 'with no device_id' do
      it 'sends an identify to AmplitudeAPI' do
        identification = AmplitudeAPI::Identification.new(
          user_id: user,
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(@described_class_instance).to receive(:identify).with(identification)

        @described_class_instance.send_identify(user, nil, first_name: 'John', last_name: 'Doe')
      end

      context 'the user is nil' do
        it 'sends an identify with the no account user' do
          identification = AmplitudeAPI::Identification.new(
            user_id: nil,
            user_properties: {
              first_name: 'John',
              last_name: 'Doe'
            }
          )
          expect(@described_class_instance).to receive(:identify).with(identification)

          @described_class_instance.send_identify(nil, nil, first_name: 'John', last_name: 'Doe')
        end
      end

      context 'the user is a user_id' do
        it 'sends an identify to AmplitudeAPI' do
          identification = AmplitudeAPI::Identification.new(
            user_id: 123,
            user_properties: {
              first_name: 'John',
              last_name: 'Doe'
            }
          )
          expect(@described_class_instance).to receive(:identify).with(identification)

          @described_class_instance.send_identify(user.id, nil, first_name: 'John', last_name: 'Doe')
        end
      end
    end
    context 'with a device_id' do
      it 'sends an identify to AmplitudeAPI' do
        identification = AmplitudeAPI::Identification.new(
          user_id: user,
          device_id: 'abc',
          user_properties: {
            first_name: 'John',
            last_name: 'Doe'
          }
        )
        expect(@described_class_instance).to receive(:identify).with(identification)

        @described_class_instance.send_identify(user, 'abc', first_name: 'John', last_name: 'Doe')
      end
    end
  end

  describe '.segmentation' do
    let(:end_time)   { Time.now }
    let(:start_time) { end_time - 60 * 60 * 24 } # -1 day

    it 'sends request to Amplitude' do
      expect(Typhoeus).to receive(:get).with(AmplitudeAPI::SEGMENTATION_URI_STRING,
                                             userpwd: "#{@described_class_instance.api_key}:#{@described_class_instance.secret_key}",
                                             params: {
                                               e:      { event_type: 'my event' }.to_json,
                                               start:  start_time.strftime('%Y%m%d'),
                                               end:    end_time.strftime('%Y%m%d'),
                                               s:      [{ prop: 'foo', op: 'is', values: %w(bar) }.to_json]
                                             })

      @described_class_instance.segmentation({ event_type: 'my event' }, start_time, end_time,
                                   s: [{ prop: 'foo', op: 'is', values: %w(bar) }]
                                  )
    end
  end

  describe '#body' do
    it 'adds an api key' do
      event = AmplitudeAPI::Event.new(
        user_id: user,
        event_type: 'test_event',
        event_properties: {
          test_property: 1
        }
      )
      body = @described_class_instance.track_body(event)
      expect(body[:api_key]).to eq('stub api key')
    end

    it 'creates an event' do
      event = AmplitudeAPI::Event.new(
        user_id: 23,
        event_type: 'test_event',
        event_properties: {
          foo: 'bar'
        },
        user_properties: {
          abc: '123'
        },
        ip: '8.8.8.8'
      )
      body = @described_class_instance.track_body(event)

      expected = JSON.generate(
        [
          {
            event_type: 'test_event',
            user_id: 23,
            event_properties: {
              foo: 'bar'
            },
            user_properties: {
              abc: '123'
            },
            ip: '8.8.8.8'
          }
        ]
      )
      expect(body[:event]).to eq(expected)
    end
  end
end
