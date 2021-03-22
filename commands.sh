# Building the recommender

#Get MovieLens Database
wget http://files.grouplens.org/datasets/movielens/ml-1m.zip
unzip ml-1m.zip

# Convert ratings.dat, trade “::” for “,”, and take only the first three columns:
cat ml-1m/ratings.dat | sed 's/::/,/g' | cut -f1-3 -d, > ratings.csv

#Put ratings file into HDFS:
hadoop fs -put ratings.csv /ratings.csv

#Run the recommender job
mahout recommenditembased --input /ratings.csv --output recommendations --numRecommendations 10 --outputPathForSimilarityMatrix similarity-matrix --similarityClassname SIMILARITY_COSINE

#See the results
hadoop fs -ls recommendations
hadoop fs -cat recommendations/part-r-00000 | head


#Building the service

# Install python packages
sudo pip3 install twisted
sudo pip3 install klein
sudo pip3 install redis


# Install the redis
wget http://download.redis.io/releases/redis-2.8.7.tar.gz
tar xzf redis-2.8.7.tar.gz
cd redis-2.8.7
make
./src/redis-server &

#Start the web service.
twistd -noy hello.py &

#Test the web service with user id “37”:
curl localhost:8081/37
