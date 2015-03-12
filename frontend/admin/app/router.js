import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: '/redesign/admin/'
});

Router.map(function() {
  this.resource('containers', { path: '/' }, function() {
    this.route('new', { path: '/containers/new' });
    this.route('edit', { path: '/containers/:container_id' });
  });
});

export default Router;
