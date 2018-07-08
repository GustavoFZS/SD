require 'bunny'

class ServidorSincrono
  def initialize
    @connection =  Bunny.new(automatically_recover: false, host:  'localhost', port:  '5672')
    @connection.start
    @channel = @connection.create_channel
  end

  def start()
    @queue1 = channel.queue('method1')
    @queue2 = channel.queue('method2')
    @queue3 = channel.queue('method3')
    @queue4 = channel.queue('method4')
	@queue5 = channel.queue('method5')
    @exchange = channel.default_exchange
  end

  def execute()
	subscribe_to_queue1
	subscribe_to_queue2
	subscribe_to_queue3
	subscribe_to_queue4
	subscribe_to_queue5
  end

  def stop
    channel.close
    connection.close
  end

  private

  attr_reader :channel, :exchange, :queue1, :queue2, :queue3, :queue4, :queue5, :connection

  def subscribe_to_queue1
    queue1.subscribe(block: false) do |_delivery_info, properties|
      result = metodo1()

      exchange.publish(
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

      exchange.publish(
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

      exchange.publish(
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

      exchange.publish(
          result.to_s,
          routing_key: properties.reply_to,
          correlation_id: properties.correlation_id
      )
    end
  end
  
  def subscribe_to_queue5
    queue5.subscribe(block: false) do |_delivery_info, properties, payload|
	  
      result = metodo5(payload)

      exchange.publish(
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
    return [value1, value2, value3, value4, value5, value6, value7, value8]
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
server = ServidorSincrono.new
server.start()
while(true)
  server.execute()
end