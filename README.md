BubbleMaps
==========

BubbleMaps is an experiment in high-level data visualization of public discourse. The project is live at:

http://www.bubblmaps.com

BubbleMaps is built for people who want a quick, high level scan what a community is talking about online. Say I love biking in St. Louis, Missouri and am deeply immersed in STL bike scene. I may want to connect with people in the St. Louis skateboarding scene, but I don't really know where to start. A BubbleMap will allow me to quickly visualize what the St. Louis skater community is talking about so that I can see which discussions overlap with my community's interests and begin to connect around common ground. BubbleMaps are currently used by members of the scientific research community to facilitate interdisciplenary collaboration, and by community organizations to inform social media strategy.

BubbleMaps has two core components:

1. A data aggregator build in Ruby on Rails which collects information from the web, analyzes it, and saves it in a consistent format.
2. A data visualization (located in apps/helpers/pages_helper.rb) which takes this aggregated data an presents it as a bubble diagram.

Data is currently aggregated from:

PubMed- For use by research scientists.
Twitter- For use tracking social media trends.
The New York Times- Because sometimes I get unplugged for a week and lose touch with what the big news stories are.

Support exists for tracking of arbitrary XML and RSS feeds, though an elegant system for inputing them has yet to be implemented.

To start playing with BubbleMaps:
---------------------------------

1. Fork this branch and create a local instance.
2. Run bundle install, create a database, etc.
3. Set twitter API keys as environmental variables (TWITTER_KEY, TWITTER_SECRET, OATH_TOKEN, OATH_TOKEN_SECRET)
3. Access the console and type 'Map.twitter_map('search_term')' or 'Map.pubmed_map('search_term')'.

