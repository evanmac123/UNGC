# COE Refactors

The main goal here is to reduce the amount of type-checking and conditionals throughout the entire COP structure, from views, to controllers, to models.

## Refactor recommendations

* Remove coupling to the approval workflow, as it's no longer being used (mostly implemented)

* Move the conditional-filled display logic from the admin/cops_controller into a Presenter class (implemented).

* Use some better metaprogramming when displaying the show and results partials.

* Add more tests that verify each different type of COP type/behaviour. There's currently a lack of tests in terms of different types of COPs, it would be best to improve this early on in the refactor, since moving things around may have unexpected side-effects.

* Use a STI approach: the quickest and possibly most effective refactor would be to move the COP model to a STI approach, whereby storing each different type in a new column on the table. That way, each type has its own subclass and have much cleaner methods that aren't full of conditionals. Taking advantage of a base class seems really useful here.

For example, these types of constants would be better served on specific subclasses: https://github.com/unspace/UNGC/blob/master/app/models/communication_on_progress.rb#L92-L133

* Defining the types is still a bit hazy at this point, as there are many differentiations:

For forms:
type_of_cop defines:
* non_business (COE)
* basic (business COP)
* intermediate (business COP)
* advanced (business COP)
* grace (applies to any type of organization)
* lead (business only?)

Within those types there are other considerations that seem to apply more generally across them, which indicates why it would be good to have a base class.

* Additionally, reducing the amount of model methods would be ideal. Some of these are use for display only, and would better serve as view helpers.
These methods are not necessary at all: https://github.com/unspace/UNGC/blob/master/app/models/communication_on_progress.rb#L149-L171

* If we want to go deeper, then separating the COP model into different models would also work, especially when it comes to any distinction with columns. Some polymorphism may also be required.
