# CourtReserver

## Overview
- This app allows for users to create and save reservations for a tennis court of their choosing. They can also update and delete their current reservations, as well as join an existing reservation that another user has set up.

### NOTE
- this setup contains a rakefile with helpful process reminders

## Table of Contents
- Getting Started
- Gems Used
- Contributors
- Known Issues
--- 

## Getting started

Just run 'bundle' in your terminal to install all the gems. When you're ready to launch the app, run 'rake start' and follow the prompts in the terminal! Have fun.

---

## Gems-used

`tty-prompt` - and extremely useful interface for prompting user input (https://github.com/piotrmurach/tty-prompt)

## Contributors

- Kwaku Gyapong
- Max Beneke

## Known Issues

The main issue we currently have is that, while our users can join a reservation and close said reservation to other users, the joining user cannot currently view this reservation as a 'joiner'. Similarly, the joined user cannot see who joined. We hope to add this update soon. 

## License

MIT License

Copyright (c) [2021] [Max Beneke, Kwaku Gyapong]

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
