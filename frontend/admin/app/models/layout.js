import Model from 'admin/lib/model';
import Ember from 'ember';

var Layout = Model.extend({
  // label:             attr('string'),
  // hasManyContainers: attr('boolean'),
  // containersCount:   attr('number'),
  hasOneContainer: Ember.computed.not('hasManyContainers')
});

Layout.path = '/redesign/admin/api/layouts';

export default Layout;
