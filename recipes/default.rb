#
# Cookbook Name:: lampy
# Recipe:: default
#
# Copyright (C) 2018 euonymus
#
# All rights reserved - Do Not Redistribute
#

include_recipe 'lampy::server'
include_recipe 'lampy::apache'
include_recipe 'lampy::mysql'
include_recipe 'lampy::python'
include_recipe 'lampy::certbot'
