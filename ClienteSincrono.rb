require 'bunny'
require 'thread'
require 'json'

class Aula
	attr_accessor :curso, :professor
	
	def initialize(curso, professor)
		@curso = curso
		@professor = professor
	end
	
	def getJson
		{'curso': curso.to_s, 'professor': professor.nome.to_s}
	end
end

class Professor
	attr_accessor :nome
	
	def initialize(nome)
		@nome = nome
	end
end

class Sala
	attr_accessor :aulas, :alunos
	
	def initialize(aulas, alunos)
		@alunos = alunos
		@aulas = aulas
	end
	
	def getJson
		json = {}
		aulasJson = {}
		aulas.each_with_index do |aula, i|
			aulasJson[i.to_s] = aulasJson[i.to_s].nil? ? aula.getJson() : aulasJson[i.to_s].merge(aula.getJson())
		end
		alunosJson = {}
		alunos.each_with_index do |aluno, i|
			alunosJson[i.to_s] = alunosJson[i.to_s].nil? ? aluno.getJson() : alunosJson[i.to_s].merge(aluno.getJson())
		end
		json['aulas'] = aulasJson
		json['alunos'] = alunosJson
		json
	end
end

class Aluno
	attr_accessor :nome, :aulas
	
	def initialize(nome, aulas)
		@nome = nome
		@aulas = aulas
	end
	
	def getJson
		json = {'nome': nome.to_s}
		aulasJson = {}
		aulas.each_with_index  do |aula, i|
			aulasJson[i.to_s] = aulasJson[i.to_s].nil? ? aula.getJson() : aulasJson[i.to_s].merge(aula.getJson())
		end
		json['aulas'] = aulasJson
		json
	end
end

class ClienteSincrono
  attr_accessor :call_id, :response, :lock, :condition, :connection,
                :channel, :server_queue_name, :reply_queue, :exchange

  def initialize()
    @connection = Bunny.new(automatically_recover: false, host:  'localhost', port:  '5672')
    @connection.start

    @channel = connection.create_channel
    @exchange = channel.default_exchange

    setup_reply_queue
  end

  def call1()
    @call_id = generate_uuid
						  
    exchange.publish(URI.encode_www_form({}),
                      routing_key: 'method1',
                      correlation_id: call_id,
                      reply_to: reply_queue.name)
	
	lock.synchronize { condition.wait(lock) }
						  	  
	response
  end

  def call2()
    @call_id = generate_uuid

    exchange.publish(URI.encode_www_form({value: 12.to_f}),
                      routing_key: 'method2',
                      correlation_id: call_id,
                      reply_to: reply_queue.name)
					  
	lock.synchronize { condition.wait(lock) }

	response
  end

  def call3()
    @call_id = generate_uuid

    exchange.publish(URI.encode_www_form({value1: 0, value2: 1, value3: 2, value4: 3, value5: 5, value6: 8, value7: 12, value8: 20}),
                      routing_key: 'method3',
                      correlation_id: call_id,
                      reply_to: reply_queue.name)
					  
	lock.synchronize { condition.wait(lock) }

	response
  end

  def call4(n)
    @call_id = generate_uuid

	exchange.publish(URI.encode_www_form({value: n}),
					  routing_key: 'method4',
					  correlation_id: call_id,
					  reply_to: reply_queue.name)
					  
	lock.synchronize { condition.wait(lock) }

	response
  end
  
  def call5(object)
    @call_id = generate_uuid
	
    exchange.publish(URI.encode_www_form({value: object}),
                      routing_key: 'method5',
                      correlation_id: call_id,
                      reply_to: reply_queue.name)
					  
	lock.synchronize { condition.wait(lock) }

	response
  end

  def stop
    channel.close
    connection.close
  end

  private

  def setup_reply_queue
    @lock = Mutex.new
    @condition = ConditionVariable.new
    that = self
    @reply_queue = channel.queue('', exclusive: true)

    reply_queue.subscribe do |_delivery_info, properties, payload|
      if properties[:correlation_id] == that.call_id
        that.response = payload.to_json
		that.lock.synchronize { that.condition.signal }
      end
    end	
  end

  def generate_uuid
    "#{rand}#{rand}#{rand}"
  end

end

puts 'Enviando requisições...'
client = ClienteSincrono.new()
rodadas = 1

n = 0
while (n < 100)  do
	n = n + 1
	
	i = 0
	tempo_final = 0
	while (i < rodadas)  do
		tempo = Time.now
		client.call1()
		tempo_final = tempo_final + (Time.now - tempo)
		i = i + 1
	end
	puts '1 ' + (tempo_final).to_s

	i = 0
	tempo_final = 0
	while (i < rodadas)  do
		tempo = Time.now
		client.call2()
		tempo_final = tempo_final + (Time.now - tempo)
		i = i + 1
	end
	puts '2 ' + (tempo_final).to_s

	i = 0
	tempo_final = 0
	while (i < rodadas)  do
		tempo = Time.now
		client.call3()
		tempo_final = tempo_final + (Time.now - tempo)
		i = i + 1
	end
	puts '3 ' + (tempo_final).to_s

	j = 0
	while(j < 18)
		msg = "0"*(2**j)
		i = 0
		tempo_final = 0
		while (i < rodadas)  do
			tempo = Time.now
			client.call4(msg)
			tempo_final = tempo_final + (Time.now - tempo)
			i = i + 1
		end
		puts '4 ' + (tempo_final).to_s
		j = j + 1
	end

	professores = [Professor.new('Daniel'), Professor.new('Karla'), Professor.new('Edmir')]
	aulas = [Aula.new('Sistemas Distribuidos', professores[0]), Aula.new('Matematica discreta', professores[1]), Aula.new('Economia', professores[2])]
	alunos = [Aluno.new('Japeto', [aulas[0], aulas[1], aulas[2]]), Aluno.new('Jesus', [aulas[2]]), Aluno.new('Alex', [aulas[0], aulas[1]])]
	sala = Sala.new(aulas, alunos).getJson()

	i = 0
	tempo_final = 0
	while (i < rodadas)  do
		tempo = Time.now
		client.call5(sala)
		tempo_final = tempo_final + (Time.now - tempo)
		i = i + 1
	end
	puts '5 ' + (tempo_final).to_s
end

puts 'Requisições enviadas '
