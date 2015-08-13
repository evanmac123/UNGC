import Ember     from 'ember';
import Container from 'sitemap/models/container';

export default Ember.Route.extend({
  model: function() {
    return Container.needsApproval();
  }
});
