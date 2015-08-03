require 'hiera'
require 'redis'

describe 'hiera-redis' do
  let(:hiera) do
    Hiera.new(config: {
                default: nil,
                backends: ['redis'],
                scope: {},
                key: nil,
                verbose: false,
                resolution_type: :priority,
                format: :ruby })
  end
  let(:redis) { Redis.new }

  it 'works' do
    redis.set('common:foo', 'bar')
    expect(hiera.lookup('foo', '', '')).to eq('bar')
  end
end
