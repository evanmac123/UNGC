import DS from 'ember-data';

export default DS.Model.extend({
  title: DS.attr(),
  startsAt: DS.attr('date')
});
