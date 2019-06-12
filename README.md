# Flickr-Importer

[![Build Status](https://travis-ci.org/MichiganCliffy/flickr-importer.svg?branch=master)](https://travis-ci.org/MichiganCliffy/flickr-importer)

This is a utility script that brings metadata from flickr and stores it to a MongoDB database for faster retrieval. I had performance issues getting the metadata in a way that I wanted, so I came up with an approach to _cache_ it in MongoDB and update it every 8 hours.

This utility was written in Ruby as a learning exercise to better understand how Ruby works.