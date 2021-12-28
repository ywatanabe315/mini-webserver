class SampleRackApp
  def call(env)
    status = 200
    headers = {'Hoge': 'hoge'}
    body = ['bodybody']
    [status, headers, body]
  end
end