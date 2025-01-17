# frozen_string_literal: true

# -- copyright
# OpenProject is an open source project management software.
# Copyright (C) 2023 the OpenProject GmbH
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License version 3.
#
# OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
# Copyright (C) 2006-2013 Jean-Philippe Lang
# Copyright (C) 2010-2013 the ChiliProject Team
#
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# as published by the Free Software Foundation; either version 2
# of the License, or (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
#
# See COPYRIGHT and LICENSE files for more details.
# ++

require 'spec_helper'
require 'services/base_services/behaves_like_create_service'

RSpec.describe WorkPackageMembers::CreateService do
  let(:user) { build_stubbed(:user) }
  let(:role) { build_stubbed(:view_work_package_role) }
  let(:work_package) { build_stubbed(:work_package) }
  let(:instance) { described_class.new(user:) }

  let(:params) { { principal: user, roles: [role], entity: work_package, project: work_package.project } }

  subject(:service_call) { instance.call(params) }

  def stub_notifications
    allow(OpenProject::Notifications)
      .to receive(:send)
  end

  before { stub_notifications }

  it_behaves_like 'BaseServices create service' do
    let(:model_class) { Member }
    let(:call_attributes) { { principal: user, roles: [role], entity: work_package, project: work_package.project } }

    context 'when successful' do
      it 'sends a notification' do
        service_call

        expect(OpenProject::Notifications)
          .to have_received(:send)
                .with(OpenProject::Events::WORK_PACKAGE_SHARED,
                      work_package_member: model_instance,
                      send_notifications: true)
      end
    end
  end
end
