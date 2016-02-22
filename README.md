ScanDex
=======

Index your scanned documents.

Install
=======

To install scandex itself

    gem install scandex

In order to index files though, scandex relies on imagemagick, ghostscript and tesseract.

    brew install imagemagick gs tesseract

Usage
=====

To add documents to the index

    scandex index ~/Documents/*.pdf

To search for documents

    scandex search "Taxes"

To list documents

    scandex list

You can also have scandex just watch a directory for incoming new documents

    scandex watch ~/Documents/Scanner

Configuration
=============

By default scandex stores its index in $HOME/.scandex.db but you can use -f PATH to specify where the database should be stored instead.
