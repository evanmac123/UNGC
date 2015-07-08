import DS from 'ember-data';

export default DS.ActiveModelAdapter.extend({
  namespace: 'redesign/admin/api',
  shouldBackgroundReloadRecord() { return false; }
});
