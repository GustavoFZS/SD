require 'bunny'

class ServidorAssincrono
  def initialize
    @channel1 = Bunny.new.start.create_channel
	@channel2 = Bunny.new.start.create_channel
	@channel3 = Bunny.new.start.create_channel
	@channel4 = Bunny.new.start.create_channel
	@channel5 = Bunny.new.start.create_channel
  end

  def start()
    @queue1 = channel1.queue('method1')
    @queue2 = channel2.queue('method2')
    @queue3 = channel3.queue('method3')
    @queue4 = channel4.queue('method4')
	@queue5 = channel5.queue('method5')
    @exchange1 = channel1.default_exchange
	@exchange2 = channel2.default_exchange
	@exchange3 = channel3.default_exchange
	@exchange4 = channel4.default_exchange
	@exchange5 = channel5.default_exchange
  end

  def execute()
	subscribe_to_queue1
	subscribe_to_queue2
	subscribe_to_queue3
	subscribe_to_queue4
	subscribe_to_queue5
  end

  def stop
    channel1.close
    channel2.close
	channel3.close
	channel4.close
	channel5.close
  end

  private

  attr_reader :channel1, :channel2, :channel3, :channel4, :channel5, 
  :exchange1, :exchange2, :exchange3, :exchange4, :exchange5, :queue1,
  :queue2, :queue3, :queue4, :queue5, :connection

  def subscribe_to_queue1
    queue1.subscribe(block: false) do |_delivery_info, properties|
      result = metodo1()

      exchange1.publish(
	      result.to_s,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end

  def subscribe_to_queue2
    queue2.subscribe(block: false) do |_delivery_info, properties, payload|
      params =  URI.decode_www_form(payload)
	  result = metodo2(params[0][1])

      exchange2.publish(
          result.to_s,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end

  def subscribe_to_queue3
    queue3.subscribe(block: false) do |_delivery_info, properties, payload|
	  params =  URI.decode_www_form(payload)
      result = metodo3(params[0][1].to_f, params[1][1].to_f, params[2][1].to_f, params[3][1].to_f, params[4][1].to_f, params[5][1].to_f, params[6][1].to_f, params[7][1].to_f)

      exchange3.publish(
          result.to_s,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end

  def subscribe_to_queue4
    queue4.subscribe(block: false) do |_delivery_info, properties, payload|
	  params =  URI.decode_www_form(payload)
      result = metodo4(params[0][1])

      exchange4.publish(
          result.to_s,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end
  
  def subscribe_to_queue5
    queue5.subscribe(block: false) do |_delivery_info, properties, payload|
	  
      result = metodo5(payload)

      exchange5.publish(
          result,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end

  def metodo1()
	#puts 'Método 1 foi executado.'	
  end

  def metodo2(value)
	#puts 'Método 2 foi executado.'
    return value
  end

  def metodo3(value1, value2, value3, value4, value5, value6, value7, value8)
	#puts 'Método 3 foi executado.'
    return value6
  end

  def metodo4(value)
	#puts 'Método 4 foi executado.'
    return value
  end
  
  def metodo5(value)
    #puts 'Método 5 foi executado.'
    return value
  end

end

puts 'Aguardando requisições...'
server = ServidorAssincrono.new
server.start()
while(true)
  server.execute()
end