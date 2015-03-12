import Model from 'admin/lib/model';
import Ember from 'ember';

var Layout = Model.extend({
  hasOneContainer: Ember.computed.not('hasManyContainers')
});

Layout.path = '/redesign/admin/api/layouts';

export default Layout;
