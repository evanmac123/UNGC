import Ember from 'ember';
import Layout from 'admin/models/layout';
import Container from 'admin/models/container';

var RSVP = Ember.RSVP;

export default Ember.Route.extend({
  model() {
    return RSVP.hash({
      layouts:   Layout.get(),
      container: Container.create()
    });
  },

  actions: {
    save(container) {
      return container.post().then(
        function(model) {
          console.log(model);
        },

        function(error) {
          console.log(error);
        }
      );
    }
  }
});
