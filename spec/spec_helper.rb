require_relative '../lib/proxy_record'
require 'active_record'
require 'securerandom'

FileUtils.rm_rf('tmp')

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: 'tmp/proxy_record_db')
ActiveRecord::Base.connection.execute('create table users (login varchar(255))')
