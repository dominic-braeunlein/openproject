// -- copyright
// OpenProject is an open source project management software.
// Copyright (C) 2012-2022 the OpenProject GmbH
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License version 3.
//
// OpenProject is a fork of ChiliProject, which is a fork of Redmine. The copyright follows:
// Copyright (C) 2006-2013 Jean-Philippe Lang
// Copyright (C) 2010-2013 the ChiliProject Team
//
// This program is free software; you can redistribute it and/or
// modify it under the terms of the GNU General Public License
// as published by the Free Software Foundation; either version 2
// of the License, or (at your option) any later version.
//
// This program is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with this program; if not, write to the Free Software
// Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
//
// See COPYRIGHT and LICENSE files for more details.
//++

import { HalResource } from 'core-app/features/hal/resources/hal-resource';
import { CollectionResource } from 'core-app/features/hal/resources/collection-resource';
import { InputState } from 'reactivestates';

export class SchemaResource extends HalResource {
  public get state():InputState<this> {
    return this.states.schemas.get(this.href as string) as any;
  }

  public get availableAttributes() {
    return _.keys(this.$source).filter((name) => name.indexOf('_') !== 0);
  }

  // Find the attribute name with a matching (localized) name;
  public attributeFromLocalizedName(name:string):string|null {
    let match:string|null = null;

    for (const attribute of this.availableAttributes) {
      const fieldSchema = this[attribute];
      if (fieldSchema?.name === name) {
        match = attribute;
        break;
      }
    }

    return match;
  }
}

export class SchemaAttributeObject<T = HalResource> {
  public type:string;

  public name:string;

  public required:boolean;

  public hasDefault:boolean;

  public writable:boolean;

  public allowedValues:T[] | CollectionResource<T>;
}
