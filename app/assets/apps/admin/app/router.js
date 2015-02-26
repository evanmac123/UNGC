import Ember from 'ember';
import config from './config/environment';

var Router = Ember.Router.extend({
  location: config.locationType,
  rootURL: '/redesign/admin/'
});

Router.map(function() {
  this.route('sitemap', { path: '/' });
});

export default Router;
