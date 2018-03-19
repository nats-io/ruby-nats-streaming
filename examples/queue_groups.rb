# Copyright 2017-2018 The NATS Authors
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
# http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

require 'stan/client'

opts = { servers: ["nats://127.0.0.1:4222"] }

sc1 = STAN::Client.new
sc1.connect("test-cluster", "client-1", nats: opts)

sc2 = STAN::Client.new
sc2.connect("test-cluster", "client-2", nats: opts)

sc3 = STAN::Client.new
sc3.connect("test-cluster", "client-3", nats: opts)

group = [sc1, sc2, sc3]

group.each do |sc|
  # Subscribe to with queue group 'bar'
  sc.subscribe("foo", queue: "bar") do |msg|
    puts "[#{sc.client_id}] Received a message on queue subscription   (seq: #{msg.seq}): #{msg.data}"
  end

  # Notice that you can have a regular subscriber on that subject
  sc.subscribe("foo") do |msg|
    puts "[#{sc.client_id}] Received a message on regular subscription (seq: #{msg.seq}): #{msg.data}"
  end
end

# Clients receives message sequence 1-40 on regular subscription.
1.upto(40) { |n| sc2.publish("foo", "hello-#{n}") }

# When the last member leaves the group, that queue group is removed
group.each do |sc|
  sc.close
end
