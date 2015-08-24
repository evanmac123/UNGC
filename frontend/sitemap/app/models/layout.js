import Model from 'sitemap/lib/model';
import Ember from 'ember';

var Layout = Model.extend({
  hasOneContainer: Ember.computed.not('hasManyContainers')
});

Layout.path = '/sitemap/api/layouts';

export default Layout;
