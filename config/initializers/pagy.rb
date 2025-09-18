# Pagy initializer file
# Encoding: utf-8
# frozen_string_literal: true

# Pagy DEFAULT Variables
# See https://ddnexus.github.io/pagy/api/pagy#variables

Pagy::DEFAULT[:items] = 20        # items per page
Pagy::DEFAULT[:size]  = [ 1, 4, 4, 1 ] # nav bar links

# Pagy variables for API
Pagy::DEFAULT[:limit] = 100       # max items per page when using limit param
Pagy::DEFAULT[:max_items] = 100   # max items per page

# Include Pagy Backend in controllers
require "pagy/extras/overflow"
Pagy::DEFAULT[:overflow] = :last_page
