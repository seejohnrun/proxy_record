require_relative '../lib/proxy_record'
require_relative '../lib/lite_record'
require 'active_record'
require 'securerandom'

FileUtils.rm_rf('tmp')

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'tmp/proxy_record_db')
ActiveRecord::Base.connection.execute('create table users (id integer primary key, login varchar(255))')
ActiveRecord::Base.connection.execute('create table posts (id integer primary key, title varchar(255), user_id integer)')

RSpec.configure do |c|
  c.before :each do
    ActiveRecord::Base.connection.execute('delete from users')
    ActiveRecord::Base.connection.execute('delete from posts')
  end
end
