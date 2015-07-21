import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType
});

Router.map(function() {
  this.resource('sitemap', { path: '/sitemap'}, function() {
    this.resource('containers', { path: '/' }, function() {
      this.route('new', { path: '/containers/new/in/:parent_container' });
      this.route('edit', { path: '/containers/:container_id' });
      this.route('edit-slug', { path: '/containers/:container_id/edit-slug' });
      this.route('needs-approval');
    });
    this.resource('images', function() {
      this.route('edit', { path: '/:image_id'});
    });
  });
});

export default Router;
