require 'hiera'
require 'redis'

describe 'hiera-redis' do
  let(:hiera) do
    Hiera.new(config: {
                default: nil,
                backends: ['redis'],
                hierarchy: %w(main common),
                scope: {},
                key: nil,
                verbose: false,
                resolution_type: :priority,
                format: :ruby })
  end
  let(:redis) { Redis.new }

  before(:each) do
    redis.flushdb
  end

  it 'works with a string key' do
    redis.set('common:foo', 'bar')
    expect(hiera.lookup('foo', '', '')).to eq('bar')
  end

  it 'works with a hash key' do
    redis.hset('common:foo', 'ckey', 'cvalue')
    redis.hset('main:foo', 'key', 'value')
    expect(hiera.lookup('foo', '', '')).to eq('key' => 'value')
    expect(hiera.lookup('foo', '', '', '', :hash)).to eq('key' => 'value', 'ckey' => 'cvalue')
    expect(hiera.lookup('foo', '', '', '', {})).to eq('key' => 'value', 'ckey' => 'cvalue')
  end

  it 'works with list keys' do
    redis.rpush('common:foo', 'value')
    redis.rpush('common:foo', 'value2')
    expect(hiera.lookup('foo', '', '')).to eq(%w(value value2))
  end

  it 'works with set keys' do
    redis.sadd('common:foo', 'value')
    expect(hiera.lookup('foo', '', '')).to eq(%w(value))
  end

  it 'obey the hierarchy' do
    redis.set('common:foo', 'common')
    redis.set('main:foo', 'main')

    expect(hiera.lookup('foo', '', '')).to eq('main')
    # now as an array, order is important.
    expect(hiera.lookup('foo', '', '', '', :array)).to eq(%w(main common))
  end
end
