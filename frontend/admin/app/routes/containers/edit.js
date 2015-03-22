import Ember from 'ember';
import Container from 'admin/models/container';

export default Ember.Route.extend({
  model(params) {
    return Ember.RSVP.hash({
      container: Container.get(params.container_id)
    });
  },

  renderTemplate() {
    this.render('containers/form');
  },

  actions: {
    save(record) {
      record.save();
    }
  }
});
