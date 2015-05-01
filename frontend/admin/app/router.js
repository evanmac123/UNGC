import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.resource('admin', { path: '/redesign/admin'}, function() {
    this.resource('containers', { path: '/' }, function() {
      this.route('new', { path: '/containers/new/in/:parent_container' });
      this.route('edit', { path: '/containers/:container_id' });
      this.route('needs-approval');
    });
    this.resource('images');
  });
});

export default Router;
