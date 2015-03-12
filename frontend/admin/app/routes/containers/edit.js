import Ember from 'ember';
import Container from 'admin/models/container';

export default Ember.Route.extend({
  model(params) {
    return Container.get(params.container_id);
  }
});
