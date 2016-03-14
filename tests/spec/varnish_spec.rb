require 'serverspec'
require 'specinfra/backend/docker_compose'

set :docker_compose_file, 'compose.yml'
set :docker_compose_container, :varnish
set :docker_wait, 2
set :backend, :docker_compose

describe 'compose.yml run' do
  describe process("varnishd") do
    it { should be_running }
  end
  describe port(5000) do
    it { should be_listening }
  end
end
