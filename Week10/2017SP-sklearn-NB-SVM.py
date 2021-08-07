
# Step 1: read in data
import pandas as p
train=p.read_csv("train.tsv", delimiter='\t')
y=train['Sentiment'].values
X=train['Phrase'].values

# split data for hold-out test
from sklearn import cross_validation
X_train, X_test, y_train, y_test = cross_validation.train_test_split(X, y, test_size=0.4, random_state=0)
X_train.shape
y_train.shape
X_test.shape
y_test.shape

# Step 2: vectorization
from sklearn.feature_extraction.text import CountVectorizer
#from sklearn.feature_extraction.text import TfidfVectorizer

# term frequency vectorizer
unigram_count = CountVectorizer(encoding='latin-1', min_df=5, stop_words=None)

# Step 2.1: vectorizing the training data

# fit and transform
# fit: to gather the vocabulary
# transform: to convert each doc to vector based on the vocabulary

X_train_vec = unigram_count.fit_transform(X_train)

# check the content of a vector
X_train_vec.shape
X_train_vec[0].toarray()

# check the size of the constructed vocabulary
len(unigram_count.vocabulary_)

# print out the entire vocabulary, each row includes the word and its index
unigram_count.vocabulary_

# check word index in vocabulary
unigram_count.vocabulary_.get('character')

# Step 2.2: vectorizing the test data

# use the vocabulary constructed from the training data to vectorize the test data. 
# Therefore, use "transform", not "fit_transform", because "fit" would generate a vocabulary from the test data
X_test_vec = unigram_count.transform(X_test)

# print out #examples and #features in the test set
X_test_vec.shape

# Step 4: train a classifier

# import the MNB module
from sklearn.naive_bayes import MultinomialNB

# initialize the MNB model
nb_clf= MultinomialNB()

# use the training data to train the MNB model
nb_clf.fit(X_train_vec,y_train)

# Step 5: test the classifier

# test the classifier on the test data set, print accuracy score
nb_clf.score(X_test_vec,y_test)

# print confusion matrix (row: ground truth; col: prediction)
from sklearn.metrics import confusion_matrix
y_pred = nb_clf.fit(X_train_vec, y_train).predict(X_test_vec)
cm=confusion_matrix(y_test, y_pred)
print(cm)

# Step 6: write the prediction output to file
y_pred=nb_clf.predict(X_test_vec)
output = open('data/output.csv', 'w')
for x, value in enumerate(y_pred):
  output.write(str(value) + '\n') 
output.close()

# check out http://scikit-learn.org/stable/auto_examples/plot_confusion_matrix.html

# precision & recall
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
precision_score(y_test, y_pred, average=None)
recall_score(y_test, y_pred, average=None)

## interpreting naive Bayes models
## by consulting the sklearn documentation you can also find out how to print the coef_ for naive Bayes 
## since it is also a linear classifier
## http://scikit-learn.org/stable/modules/generated/sklearn.naive_bayes.MultinomialNB.html
unigram_count.vocabulary_.get('worthless')
for i in range(0,5):
  print nb_clf.coef_[i][unigram_count.vocabulary_.get('worthless')]

# sample output
# -8.98942647599 logP('worthless'|very negative')
# -11.1864401922 logP('worthless'|negative')
# -12.3637684625 logP('worthless'|neutral')
# -11.9886066961 logP('worthless'|positive')
# -11.0504454621 logP('worthless'|very positive')

# the above output means the word feature "worthless" is indicating "very negative" because P('worthless'|very negative) is the greatest 

# sort the conditional probability for category 0 "very negative"
feature_ranks = sorted(zip(nb_clf.coef_[0], unigram_count.get_feature_names()))
  
## find the calculated posterior probability
nb_clf.predict_proba(X_train_vec)

## find the posterior probabilities for the first test example
nb_clf.predict_proba(X_train_vec)[0]

## sample output array([ 0.00758772,  0.10832554,  0.56456148,  0.27588508,  0.04364017]
## because the posterior probability for category 2 (neutral) is the greatest, 0.56, the prediction should be "2"

# find the category prediction for the first example
nb_clf.predict(X_train_vec)[0] 

## output should be 2


# cross validation

from sklearn.pipeline import Pipeline
nb_clf = Pipeline([('vect', CountVectorizer(encoding='latin-1')),('nb', MultinomialNB())])
scores= cross_validation.cross_val_score(nb_clf, X, y, cv=3)
avg=sum(scores)/len(scores)
avg


########## submit to Kaggle submission

# we are still using the model trained on 60% of the training data
# you can try re-train the model on the entire data set

# read in the test data

kaggle_test=p.read_csv("data/test.tsv", delimiter='\t') 

# preserve the id column of the test examples

kaggle_ids=kaggle_test['PhraseId'].values

# read in the text content of the examples

kaggle_X=kaggle_test['Phrase'].values

# vectorize the test examples using the vocabulary fitted from the 60% training data

kaggle_X_vec=unigram_count.transform(kaggle_X)

# predict using the NB classifier that we built

kaggle_pred=nb_clf.fit(X_train_vec, y_train).predict(kaggle_X_vec)

# combine the test example ids with their predictions

kaggle_submission=zip(kaggle_ids, kaggle_pred)

# prepare output file

outf=open('data/kaggle_submission.csv', 'w')

# write header

outf.write('PhraseId,Sentiment\n")

# write predictions with ids to the output file

for x, value in enumerate(kaggle_submission): outf.write(str(value[0]) + ',' + str(value[1]) + '\n')

# close the output file

outf.close()

###################
### SVM
###################

# SVM algorithm
from sklearn.svm import LinearSVC
svm_clf = LinearSVC(C=1, penalty='l1', dual=False)
svm_clf.fit(X_train_vec,y_train)
svm_clf.score(X_test_vec,y_test)
y_pred = svm_clf.fit(X_train_vec, y_train).predict(X_test_vec)
cm=confusion_matrix(y_test, y_pred)
print cm

# precision & recall
from sklearn.metrics import precision_score
from sklearn.metrics import recall_score
precision_score(y_test, y_pred, average=None)
recall_score(y_test, y_pred, average=None)

############# Look inside the LinearSVC model ############################
## LinearSVC uses a one-vs-all strategy to extend the binary SVM classifier to multi-class problems
## for the Kaggle sentiment classification problem, there are five categories 0,1,2,3,4 with 0 as very negative and 4 very positive
## LinearSVC builds five binary classifier, "very negative vs. others", "negative vs. others", "neutral vs. others", "positive vs. others", "very positive vs. others", and then pick the most confident prediction as the final prediction.

## Linear SVC also ranks all features based on their contribution to distinguish the two concepts in each binary classifier
## For category "0" (very negative), get all features and their weights and sort them in increasing order
feature_ranks = sorted(zip(svm_clf.coef_[0], unigram_count.get_feature_names()))

## get the 100 features that are best indicators of very negative sentiment (they are at the bottom of the ranked list)
very_negative_100 = feature_ranks[-100:]

## get 100 features that are least relevant to "very negative" sentiment (they are at the top of the ranked list)
Not_very_negative_100 = feature_ranks[:100]

## you can use the same method to print out the most indicative features for the other four binary classifiers

## get the confidence scores for all test examples from each of the five binary classifiers
svm_clf.decision_function(X_test_vec)
## get the confidence score for the first test example
svm_clf.decision_function(X_test_vec)[0]
## for example, output: array([-1.05306321, -0.62746206,  0.31074854, -0.89709483, -1.08343089]
## because the confidence score is the highest for category 2, the prediction should be 2. Confirm by printing out the actual prediction
svm_clf.predict(X_test_vec)[0]

# SVM cross validation
svm_clf = Pipeline([('vect', CountVectorizer(encoding='latin-1')),('svm', LinearSVC(C=1, penalty='l1', dual=False))])
scores= cross_validation.cross_val_score(svm_clf, X, y, cv=3)
avg=sum(scores)/len(scores)
avg

# MNB cross validation
from sklearn.pipeline import Pipeline
nb_clf = Pipeline([('vect', CountVectorizer(encoding='latin-1')),('nb', MultinomialNB())])
scores= cross_validation.cross_val_score(nb_clf, X, y, cv=3)
avg=sum(scores)/len(scores)
avg

