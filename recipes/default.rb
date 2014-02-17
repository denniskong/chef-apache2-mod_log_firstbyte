#
# Cookbook Name:: apache2-mod_log_firstbyte
# Recipe:: default
#
# Copyright 2012, Dennis Kong
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#
include_recipe "apache2"
include_recipe "subversion"
source_dir = "/usr/local/src"
checkout_path = ::File.join(source_dir, "mod_log_firstbyte")
mod_log_firstbyte_repo = node['mod_log_firstbyte']['repository']

directory source_dir do
  action :create
end

unless File.exists?("#{node[:apache][:libexecdir]}/mod_log_firstbyte.so")

  subversion "mod_log_firstbyte" do
    repository mod_log_firstbyte_repo
    revision "HEAD"
    destination checkout_path
    action :checkout
  end

  package "apache2-threaded-dev"

  execute "compile mod_log_firstbyte" do
    command "cd #{checkout_path} && /usr/bin/apxs2 -c mod_log_firstbyte.c"
    creates ::File.join(checkout_path, "/mod_log_firstbyte.la")
    action :run
  end

  execute "install mod_log_firstbyte" do
    command "cd #{checkout_path} && /usr/bin/apxs2 -i -a mod_log_firstbyte.la"
    creates ::File.join(node[:apache][:libexecdir], "mod_log_firstbyte.so")
    action :run
  end

end
apache_module "log_firstbyte"
