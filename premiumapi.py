'''
MIT License

Copyright (c) 2019 Luca Hammer

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
'''

'''
Example script to collect old Tweets with the Twitter Premium Search API
Article: https://lucahammer.com/?p=350

To use this script, change the constants (UPPERCASE variables) to your needs,
and run it. For example in your CLI by executing: "python premiumapi.py".

Find your app credentials here: https://developer.twitter.com/en/apps
Find your dev environment label here: https://developer.twitter.com/en/account/environments
'''

from sys import argv
API_KEY = argv[2]
API_SECRET_KEY = argv[3]
DEV_ENVIRONMENT_LABEL = argv[4]
API_SCOPE = argv[1]  # 'fullarchive' for full archive, '30day' for last 31 days

SEARCH_QUERY = argv[5]
RESULTS_PER_CALL = argv[10]  # 100 for sandbox, 500 for paid tiers
RESULTS_PER_CALL = int(RESULTS_PER_CALL)
TO_DATE = argv[9] # format YYYY-MM-DD HH:MM (hour and minutes optional)
FROM_DATE = argv[8]  # format YYYY-MM-DD HH:MM (hour and minutes optional)

MAX_RESULTS = argv[7] # Number of Tweets you want to collect
MAX_RESULTS = int(MAX_RESULTS)

FILENAME = argv[6]  # Where the Tweets should be saved

# Script prints an update to the CLI every time it collected another X Tweets
PRINT_AFTER_X = 1000


#--------------------------- STOP -------------------------------#
# Don't edit anything below, if you don't know what you are doing.
#--------------------------- STOP -------------------------------#

import yaml
config = dict(
    search_tweets_api=dict(
        account_type='premium',
        endpoint=f"https://api.twitter.com/1.1/tweets/search/{API_SCOPE}/{DEV_ENVIRONMENT_LABEL}.json",
        consumer_key=API_KEY,
        consumer_secret=API_SECRET_KEY
    )
)

with open('twitter_keys.yaml', 'w') as config_file:
    yaml.dump(config, config_file, default_flow_style=False)

    
import json
from searchtweets import load_credentials, gen_rule_payload, ResultStream

premium_search_args = load_credentials("twitter_keys.yaml",
                                       yaml_key="search_tweets_api",
                                       env_overwrite=False)

rule = gen_rule_payload(SEARCH_QUERY,
                        results_per_call=RESULTS_PER_CALL,
                        from_date=FROM_DATE,
                        to_date=TO_DATE
                        )

rs = ResultStream(rule_payload=rule,
                  max_results=MAX_RESULTS,
                  **premium_search_args)

with open(FILENAME, 'a', encoding='utf-8') as f:
    n = 0
    for tweet in rs.stream():
        n += 1
        if n % PRINT_AFTER_X == 0:
            print('{0}: {1}'.format(str(n), tweet['created_at']))
        json.dump(tweet, f)
        f.write('\n')
print('done')
