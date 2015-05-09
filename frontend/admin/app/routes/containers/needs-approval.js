import Ember     from 'ember';
import Container from 'admin/models/container';

export default Ember.Route.extend({
  model: function() {
    return Container.needsApproval();
  }
});
