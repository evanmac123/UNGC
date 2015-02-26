import Ember from 'ember';

export default Ember.Controller.extend({
  model: [
    {
      id: '1',
      rank: 100,
      title: 'Fruits',
      children: [
        { id: '2', rank: 1000, title: 'Oranges', children: [] },
        { id: '3', rank: 2000, title: 'Pears', children: [] },
        {
          id: '4',
          rank: 3000,
          title: 'Apples',
          children: [
            { id: '5', rank: 10000, title: 'Delicious', children: [] },
            { id: '6', rank: 20000, title: 'Gala', children: [] },
            { id: '7', rank: 30000, title: 'Honeycrisp', children: [] }
          ]
        }
      ]
    },
    {
      id: '8',
      rank: 200,
      title: 'Vegetables',
      children: [
        { id: '9', rank: 1000, title: 'Cucumber', children: [] },
        { id: '10', rank: 2000, title: 'Carrot', children: [] }
      ]
    }
  ]
});
