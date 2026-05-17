 
Knowledge gathered during the initial modeling is used to identify a list of features by functionally decomposing the domain into subject areas. Subject areas each contain business activities, and the steps within each business activity form the basis for a categorized feature list. Features in this respect are small pieces of client-valued functions expressed in the form "<action> <result> <object>", for example: 'Calculate the total of a sale' or 'Validate the password of a user'. Features should not take more than two weeks to complete, else they should be broken down into smaller pieces.


### Design by feature

A design package is produced for each feature. A chief programmer selects a small group of features that are to be developed within two weeks. Together with the corresponding class owners, the chief programmer works out detailed [sequence diagrams](https://en.wikipedia.org/wiki/Sequence_diagrams "Sequence diagrams") for each feature and refines the overall model. Next, the class and method prologues are written, and finally a [design inspection](https://en.wikipedia.org/wiki/Software_inspection "Software inspection") is held.

### Build by feature

After a successful design inspection for each activity to produce a feature is planned, the class owners develop code for their classes. After [unit testing](https://en.wikipedia.org/wiki/Unit_test "Unit test") and successful [code inspection](https://en.wikipedia.org/wiki/Code_review "Code review"), the completed feature is promoted to the main build.