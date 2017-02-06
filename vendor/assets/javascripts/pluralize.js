



<!DOCTYPE html>
<html lang="en" class=" emoji-size-boost is-u2f-enabled">
  <head prefix="og: http://ogp.me/ns# fb: http://ogp.me/ns/fb# object: http://ogp.me/ns/object# article: http://ogp.me/ns/article# profile: http://ogp.me/ns/profile#">
    <meta charset='utf-8'>
    

    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/frameworks-298818692f75de57d67115ca5a0c1f983d1d5ad302774216c297495f46f0a3da.css" integrity="sha256-KYgYaS913lfWcRXKWgwfmD0dWtMCd0IWwpdJX0bwo9o=" media="all" rel="stylesheet" />
    <link crossorigin="anonymous" href="https://assets-cdn.github.com/assets/github-d74d8d2476aa9341da3e77c2f74c15777c246ede555edebd433a1d0a68935dd6.css" integrity="sha256-102NJHaqk0HaPnfC90wVd3wkbt5VXt69QzodCmiTXdY=" media="all" rel="stylesheet" />
    
    
    
    

    <meta http-equiv="X-UA-Compatible" content="IE=edge">
    <meta http-equiv="Content-Language" content="en">
    <meta name="viewport" content="width=device-width">
    
    <title>pluralize/pluralize.js at master · blakeembrey/pluralize</title>
    <link rel="search" type="application/opensearchdescription+xml" href="/opensearch.xml" title="GitHub">
    <link rel="fluid-icon" href="https://github.com/fluidicon.png" title="GitHub">
    <link rel="apple-touch-icon" href="/apple-touch-icon.png">
    <link rel="apple-touch-icon" sizes="57x57" href="/apple-touch-icon-57x57.png">
    <link rel="apple-touch-icon" sizes="60x60" href="/apple-touch-icon-60x60.png">
    <link rel="apple-touch-icon" sizes="72x72" href="/apple-touch-icon-72x72.png">
    <link rel="apple-touch-icon" sizes="76x76" href="/apple-touch-icon-76x76.png">
    <link rel="apple-touch-icon" sizes="114x114" href="/apple-touch-icon-114x114.png">
    <link rel="apple-touch-icon" sizes="120x120" href="/apple-touch-icon-120x120.png">
    <link rel="apple-touch-icon" sizes="144x144" href="/apple-touch-icon-144x144.png">
    <link rel="apple-touch-icon" sizes="152x152" href="/apple-touch-icon-152x152.png">
    <link rel="apple-touch-icon" sizes="180x180" href="/apple-touch-icon-180x180.png">
    <meta property="fb:app_id" content="1401488693436528">

      <meta content="https://avatars0.githubusercontent.com/u/1088987?v=3&amp;s=400" name="twitter:image:src" /><meta content="@github" name="twitter:site" /><meta content="summary" name="twitter:card" /><meta content="blakeembrey/pluralize" name="twitter:title" /><meta content="pluralize - Pluralize or singularize any word based on a count" name="twitter:description" />
      <meta content="https://avatars0.githubusercontent.com/u/1088987?v=3&amp;s=400" property="og:image" /><meta content="GitHub" property="og:site_name" /><meta content="object" property="og:type" /><meta content="blakeembrey/pluralize" property="og:title" /><meta content="https://github.com/blakeembrey/pluralize" property="og:url" /><meta content="pluralize - Pluralize or singularize any word based on a count" property="og:description" />
      <meta name="browser-stats-url" content="https://api.github.com/_private/browser/stats">
    <meta name="browser-errors-url" content="https://api.github.com/_private/browser/errors">
    <link rel="assets" href="https://assets-cdn.github.com/">
    <link rel="web-socket" href="wss://live.github.com/_sockets/VjI6MTQ4MjIyMjc0Ojg5NjAxZjEzYzAxZTljNmZkYzViYTY0NDQ0YTkyOTc4MjJjNWMzMjQ3MGM1MDY4NjMzNDQxY2JiMjhiOTQ5OWE=--99ec83604de2a659b2bdf530929724e006be6237">
    <meta name="pjax-timeout" content="1000">
    <link rel="sudo-modal" href="/sessions/sudo_modal">
    <meta name="request-id" content="F44F:6A82:972318C:EC6C287:589807E7" data-pjax-transient>
    

    <meta name="msapplication-TileImage" content="/windows-tile.png">
    <meta name="msapplication-TileColor" content="#ffffff">
    <meta name="selected-link" value="repo_source" data-pjax-transient>

    <meta name="google-site-verification" content="KT5gs8h0wvaagLKAVWq8bbeNwnZZK1r1XQysX3xurLU">
<meta name="google-site-verification" content="ZzhVyEFwb7w3e0-uOTltm8Jsck2F5StVihD0exw2fsA">
    <meta name="google-analytics" content="UA-3769691-2">

<meta content="collector.githubapp.com" name="octolytics-host" /><meta content="github" name="octolytics-app-id" /><meta content="F44F:6A82:972318C:EC6C287:589807E7" name="octolytics-dimension-request_id" /><meta content="782360" name="octolytics-actor-id" /><meta content="renatomolina" name="octolytics-actor-login" /><meta content="dc5ba89ce29091d5b561c5cb73611cb8ea3080c8e86b27052e53fa3910e19e21" name="octolytics-actor-hash" />
<meta content="/&lt;user-name&gt;/&lt;repo-name&gt;/blob/show" data-pjax-transient="true" name="analytics-location" />



  <meta class="js-ga-set" name="dimension1" content="Logged In">



        <meta name="hostname" content="github.com">
    <meta name="user-login" content="renatomolina">

        <meta name="expected-hostname" content="github.com">
      <meta name="js-proxy-site-detection-payload" content="NzFmOGU0NGEzODQxNmJiNDFjYjZmNWY5YTY5Yjc4ZjlmNjEyMTNmNGQ2OGE1NjkyYmRiYmVkYTJhYWY3ODc4OHx7InJlbW90ZV9hZGRyZXNzIjoiMjQuODAuMTIwLjc4IiwicmVxdWVzdF9pZCI6IkY0NEY6NkE4Mjo5NzIzMThDOkVDNkMyODc6NTg5ODA3RTciLCJ0aW1lc3RhbXAiOjE0ODYzNTg1MTAsImhvc3QiOiJnaXRodWIuY29tIn0=">


      <link rel="mask-icon" href="https://assets-cdn.github.com/pinned-octocat.svg" color="#000000">
      <link rel="icon" type="image/x-icon" href="https://assets-cdn.github.com/favicon.ico">

    <meta name="html-safe-nonce" content="c370043006d5e1c32f4b504b35bbeca6bee0d02c">

    <meta http-equiv="x-pjax-version" content="3d4f9c1da2b313ad1c354185793dade2">
    

      
  <meta name="description" content="pluralize - Pluralize or singularize any word based on a count">
  <meta name="go-import" content="github.com/blakeembrey/pluralize git https://github.com/blakeembrey/pluralize.git">

  <meta content="1088987" name="octolytics-dimension-user_id" /><meta content="blakeembrey" name="octolytics-dimension-user_login" /><meta content="9152708" name="octolytics-dimension-repository_id" /><meta content="blakeembrey/pluralize" name="octolytics-dimension-repository_nwo" /><meta content="true" name="octolytics-dimension-repository_public" /><meta content="false" name="octolytics-dimension-repository_is_fork" /><meta content="9152708" name="octolytics-dimension-repository_network_root_id" /><meta content="blakeembrey/pluralize" name="octolytics-dimension-repository_network_root_nwo" />
  <link href="https://github.com/blakeembrey/pluralize/commits/master.atom" rel="alternate" title="Recent Commits to pluralize:master" type="application/atom+xml">


      <link rel="canonical" href="https://github.com/blakeembrey/pluralize/blob/master/pluralize.js" data-pjax-transient>
  </head>


  <body class="logged-in  env-production macintosh vis-public page-blob">
    <div id="js-pjax-loader-bar" class="pjax-loader-bar"><div class="progress"></div></div>
    <a href="#start-of-content" tabindex="1" class="accessibility-aid js-skip-to-content">Skip to content</a>

    
    
    



        <div class="header header-logged-in true" role="banner">
  <div class="container clearfix">

    <a class="header-logo-invertocat" href="https://github.com/" data-hotkey="g d" aria-label="Homepage" data-ga-click="Header, go to dashboard, icon:logo">
  <svg aria-hidden="true" class="octicon octicon-mark-github" height="28" version="1.1" viewBox="0 0 16 16" width="28"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
</a>


        <div class="header-search scoped-search site-scoped-search js-site-search" role="search">
  <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/blakeembrey/pluralize/search" class="js-site-search-form" data-scoped-search-url="/blakeembrey/pluralize/search" data-unscoped-search-url="/search" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
    <label class="form-control header-search-wrapper js-chromeless-input-container">
      <div class="header-search-scope">This repository</div>
      <input type="text"
        class="form-control header-search-input js-site-search-focus js-site-search-field is-clearable"
        data-hotkey="s"
        name="q"
        placeholder="Search"
        aria-label="Search this repository"
        data-unscoped-placeholder="Search GitHub"
        data-scoped-placeholder="Search"
        autocapitalize="off">
    </label>
</form></div>


      <ul class="header-nav float-left" role="navigation">
        <li class="header-nav-item">
          <a href="/pulls" aria-label="Pull requests you created" class="js-selected-navigation-item header-nav-link" data-ga-click="Header, click, Nav menu - item:pulls context:user" data-hotkey="g p" data-selected-links="/pulls /pulls/assigned /pulls/mentioned /pulls">
            Pull requests
</a>        </li>
        <li class="header-nav-item">
          <a href="/issues" aria-label="Issues you created" class="js-selected-navigation-item header-nav-link" data-ga-click="Header, click, Nav menu - item:issues context:user" data-hotkey="g i" data-selected-links="/issues /issues/assigned /issues/mentioned /issues">
            Issues
</a>        </li>
          <li class="header-nav-item">
            <a class="header-nav-link" href="https://gist.github.com/" data-ga-click="Header, go to gist, text:gist">Gist</a>
          </li>
      </ul>

    
<ul class="header-nav user-nav float-right" id="user-links">
  <li class="header-nav-item">
    
    <a href="/notifications" aria-label="You have unread notifications" class="header-nav-link notification-indicator tooltipped tooltipped-s js-socket-channel js-notification-indicator" data-channel="tenant:1:notification-changed:782360" data-ga-click="Header, go to notifications, icon:unread" data-hotkey="g n">
        <span class="mail-status unread"></span>
        <svg aria-hidden="true" class="octicon octicon-bell" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M14 12v1H0v-1l.73-.58c.77-.77.81-2.55 1.19-4.42C2.69 3.23 6 2 6 2c0-.55.45-1 1-1s1 .45 1 1c0 0 3.39 1.23 4.16 5 .38 1.88.42 3.66 1.19 4.42l.66.58H14zm-7 4c1.11 0 2-.89 2-2H5c0 1.11.89 2 2 2z"/></svg>
</a>
  </li>

  <li class="header-nav-item dropdown js-menu-container">
    <a class="header-nav-link tooltipped tooltipped-s js-menu-target" href="/new"
       aria-label="Create new…"
       data-ga-click="Header, create new, icon:add">
      <svg aria-hidden="true" class="octicon octicon-plus float-left" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 9H7v5H5V9H0V7h5V2h2v5h5z"/></svg>
      <span class="dropdown-caret"></span>
    </a>

    <div class="dropdown-menu-content js-menu-content">
      <ul class="dropdown-menu dropdown-menu-sw">
        
<a class="dropdown-item" href="/new" data-ga-click="Header, create new repository">
  New repository
</a>

  <a class="dropdown-item" href="/new/import" data-ga-click="Header, import a repository">
    Import repository
  </a>

<a class="dropdown-item" href="https://gist.github.com/" data-ga-click="Header, create new gist">
  New gist
</a>

  <a class="dropdown-item" href="/organizations/new" data-ga-click="Header, create new organization">
    New organization
  </a>



  <div class="dropdown-divider"></div>
  <div class="dropdown-header">
    <span title="blakeembrey/pluralize">This repository</span>
  </div>
    <a class="dropdown-item" href="/blakeembrey/pluralize/issues/new" data-ga-click="Header, create new issue">
      New issue
    </a>

      </ul>
    </div>
  </li>

  <li class="header-nav-item dropdown js-menu-container">
    <a class="header-nav-link name tooltipped tooltipped-sw js-menu-target" href="/renatomolina"
       aria-label="View profile and more"
       data-ga-click="Header, show menu, icon:avatar">
      <img alt="@renatomolina" class="avatar" height="20" src="https://avatars0.githubusercontent.com/u/782360?v=3&amp;s=40" width="20" />
      <span class="dropdown-caret"></span>
    </a>

    <div class="dropdown-menu-content js-menu-content">
      <div class="dropdown-menu dropdown-menu-sw">
        <div class="dropdown-header header-nav-current-user css-truncate">
          Signed in as <strong class="css-truncate-target">renatomolina</strong>
        </div>

        <div class="dropdown-divider"></div>

        <a class="dropdown-item" href="/renatomolina" data-ga-click="Header, go to profile, text:your profile">
          Your profile
        </a>
        <a class="dropdown-item" href="/renatomolina?tab=stars" data-ga-click="Header, go to starred repos, text:your stars">
          Your stars
        </a>
        <a class="dropdown-item" href="/explore" data-ga-click="Header, go to explore, text:explore">
          Explore
        </a>
          <a class="dropdown-item" href="/integrations" data-ga-click="Header, go to integrations, text:integrations">
            Integrations
          </a>
        <a class="dropdown-item" href="https://help.github.com" data-ga-click="Header, go to help, text:help">
          Help
        </a>

        <div class="dropdown-divider"></div>

        <a class="dropdown-item" href="/settings/profile" data-ga-click="Header, go to settings, icon:settings">
          Settings
        </a>

        <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/logout" class="logout-form" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="2HCErkRHodEegz6L0/wzovvxD2GXoEQaGU8TWOjCbPzzJexeCspyQhdnOuopbJ3tWu+sikkLdsYRlb5+/uin2Q==" /></div>
          <button type="submit" class="dropdown-item dropdown-signout" data-ga-click="Header, sign out, icon:logout">
            Sign out
          </button>
</form>      </div>
    </div>
  </li>
</ul>


    
  </div>
</div>


      


    <div id="start-of-content" class="accessibility-aid"></div>

      <div id="js-flash-container">
</div>


    <div role="main">
        <div itemscope itemtype="http://schema.org/SoftwareSourceCode">
    <div id="js-repo-pjax-container" data-pjax-container>
      
<div class="pagehead repohead instapaper_ignore readability-menu experiment-repo-nav">
  <div class="container repohead-details-container">

    

<ul class="pagehead-actions">

  <li>
        <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/notifications/subscribe" class="js-social-container" data-autosubmit="true" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="R+Tlo0YT8UEVfCuHNCrYYsMb5600xvwOf4UDtuLrS33P33vg2qC88o2mPrta7a4TOz3HJPhFZDrHi9w/rP7Fdg==" /></div>      <input class="form-control" id="repository_id" name="repository_id" type="hidden" value="9152708" />

        <div class="select-menu js-menu-container js-select-menu">
          <a href="/blakeembrey/pluralize/subscription"
            class="btn btn-sm btn-with-count select-menu-button js-menu-target" role="button" tabindex="0" aria-haspopup="true"
            data-ga-click="Repository, click Watch settings, action:blob#show">
            <span class="js-select-button">
              <svg aria-hidden="true" class="octicon octicon-eye" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8.06 2C3 2 0 8 0 8s3 6 8.06 6C13 14 16 8 16 8s-3-6-7.94-6zM8 12c-2.2 0-4-1.78-4-4 0-2.2 1.8-4 4-4 2.22 0 4 1.8 4 4 0 2.22-1.78 4-4 4zm2-4c0 1.11-.89 2-2 2-1.11 0-2-.89-2-2 0-1.11.89-2 2-2 1.11 0 2 .89 2 2z"/></svg>
              Watch
            </span>
          </a>
          <a class="social-count js-social-count"
            href="/blakeembrey/pluralize/watchers"
            aria-label="11 users are watching this repository">
            11
          </a>

        <div class="select-menu-modal-holder">
          <div class="select-menu-modal subscription-menu-modal js-menu-content" aria-hidden="true">
            <div class="select-menu-header js-navigation-enable" tabindex="-1">
              <svg aria-label="Close" class="octicon octicon-x js-menu-close" height="16" role="img" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48z"/></svg>
              <span class="select-menu-title">Notifications</span>
            </div>

              <div class="select-menu-list js-navigation-container" role="menu">

                <div class="select-menu-item js-navigation-item selected" role="menuitem" tabindex="0">
                  <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
                  <div class="select-menu-item-text">
                    <input checked="checked" id="do_included" name="do" type="radio" value="included" />
                    <span class="select-menu-item-heading">Not watching</span>
                    <span class="description">Be notified when participating or @mentioned.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <svg aria-hidden="true" class="octicon octicon-eye" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8.06 2C3 2 0 8 0 8s3 6 8.06 6C13 14 16 8 16 8s-3-6-7.94-6zM8 12c-2.2 0-4-1.78-4-4 0-2.2 1.8-4 4-4 2.22 0 4 1.8 4 4 0 2.22-1.78 4-4 4zm2-4c0 1.11-.89 2-2 2-1.11 0-2-.89-2-2 0-1.11.89-2 2-2 1.11 0 2 .89 2 2z"/></svg>
                      Watch
                    </span>
                  </div>
                </div>

                <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
                  <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
                  <div class="select-menu-item-text">
                    <input id="do_subscribed" name="do" type="radio" value="subscribed" />
                    <span class="select-menu-item-heading">Watching</span>
                    <span class="description">Be notified of all conversations.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <svg aria-hidden="true" class="octicon octicon-eye" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8.06 2C3 2 0 8 0 8s3 6 8.06 6C13 14 16 8 16 8s-3-6-7.94-6zM8 12c-2.2 0-4-1.78-4-4 0-2.2 1.8-4 4-4 2.22 0 4 1.8 4 4 0 2.22-1.78 4-4 4zm2-4c0 1.11-.89 2-2 2-1.11 0-2-.89-2-2 0-1.11.89-2 2-2 1.11 0 2 .89 2 2z"/></svg>
                      Unwatch
                    </span>
                  </div>
                </div>

                <div class="select-menu-item js-navigation-item " role="menuitem" tabindex="0">
                  <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
                  <div class="select-menu-item-text">
                    <input id="do_ignore" name="do" type="radio" value="ignore" />
                    <span class="select-menu-item-heading">Ignoring</span>
                    <span class="description">Never be notified.</span>
                    <span class="js-select-button-text hidden-select-button-text">
                      <svg aria-hidden="true" class="octicon octicon-mute" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8 2.81v10.38c0 .67-.81 1-1.28.53L3 10H1c-.55 0-1-.45-1-1V7c0-.55.45-1 1-1h2l3.72-3.72C7.19 1.81 8 2.14 8 2.81zm7.53 3.22l-1.06-1.06-1.97 1.97-1.97-1.97-1.06 1.06L11.44 8 9.47 9.97l1.06 1.06 1.97-1.97 1.97 1.97 1.06-1.06L13.56 8l1.97-1.97z"/></svg>
                      Stop ignoring
                    </span>
                  </div>
                </div>

              </div>

            </div>
          </div>
        </div>
</form>
  </li>

  <li>
      <div class="js-toggler-container js-social-container starring-container ">
    <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/blakeembrey/pluralize/unstar" class="starred" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="mi+tOPA61i++TpcqbPhyXwjTZfBHRhbqkVo1myg9IyGEAawVUVyR5Xl6kNqhw39IkH8McTAVVzME9ZWoWyXprQ==" /></div>
      <button
        type="submit"
        class="btn btn-sm btn-with-count js-toggler-target"
        aria-label="Unstar this repository" title="Unstar blakeembrey/pluralize"
        data-ga-click="Repository, click unstar button, action:blob#show; text:Unstar">
        <svg aria-hidden="true" class="octicon octicon-star" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z"/></svg>
        Unstar
      </button>
        <a class="social-count js-social-count" href="/blakeembrey/pluralize/stargazers"
           aria-label="397 users starred this repository">
          397
        </a>
</form>
    <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/blakeembrey/pluralize/star" class="unstarred" data-remote="true" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="dRlQnYR9ZNYLMGrPH09nau0lMwHtbipQbnzGKQ/V6S+95KZ0bKC9nIeoY4haUaAtf5Lyb9T7pfmmUfKkN2ZGiQ==" /></div>
      <button
        type="submit"
        class="btn btn-sm btn-with-count js-toggler-target"
        aria-label="Star this repository" title="Star blakeembrey/pluralize"
        data-ga-click="Repository, click star button, action:blob#show; text:Star">
        <svg aria-hidden="true" class="octicon octicon-star" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M14 6l-4.9-.64L7 1 4.9 5.36 0 6l3.6 3.26L2.67 14 7 11.67 11.33 14l-.93-4.74z"/></svg>
        Star
      </button>
        <a class="social-count js-social-count" href="/blakeembrey/pluralize/stargazers"
           aria-label="397 users starred this repository">
          397
        </a>
</form>  </div>

  </li>

  <li>
          <a href="#fork-destination-box" class="btn btn-sm btn-with-count"
              title="Fork your own copy of blakeembrey/pluralize to your account"
              aria-label="Fork your own copy of blakeembrey/pluralize to your account"
              rel="facebox"
              data-ga-click="Repository, show fork modal, action:blob#show; text:Fork">
              <svg aria-hidden="true" class="octicon octicon-repo-forked" height="16" version="1.1" viewBox="0 0 10 16" width="10"><path fill-rule="evenodd" d="M8 1a1.993 1.993 0 0 0-1 3.72V6L5 8 3 6V4.72A1.993 1.993 0 0 0 2 1a1.993 1.993 0 0 0-1 3.72V6.5l3 3v1.78A1.993 1.993 0 0 0 5 15a1.993 1.993 0 0 0 1-3.72V9.5l3-3V4.72A1.993 1.993 0 0 0 8 1zM2 4.2C1.34 4.2.8 3.65.8 3c0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3 10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zm3-10c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2z"/></svg>
            Fork
          </a>

          <div id="fork-destination-box" style="display: none;">
            <h2 class="facebox-header" data-facebox-id="facebox-header">Where should we fork this repository?</h2>
            <include-fragment src=""
                class="js-fork-select-fragment fork-select-fragment"
                data-url="/blakeembrey/pluralize/fork?fragment=1">
              <img alt="Loading" height="64" src="https://assets-cdn.github.com/images/spinners/octocat-spinner-128.gif" width="64" />
            </include-fragment>
          </div>

    <a href="/blakeembrey/pluralize/network" class="social-count"
       aria-label="44 users forked this repository">
      44
    </a>
  </li>
</ul>

    <h1 class="public ">
  <svg aria-hidden="true" class="octicon octicon-repo" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M4 9H3V8h1v1zm0-3H3v1h1V6zm0-2H3v1h1V4zm0-2H3v1h1V2zm8-1v12c0 .55-.45 1-1 1H6v2l-1.5-1.5L3 16v-2H1c-.55 0-1-.45-1-1V1c0-.55.45-1 1-1h10c.55 0 1 .45 1 1zm-1 10H1v2h2v-1h3v1h5v-2zm0-10H2v9h9V1z"/></svg>
  <span class="author" itemprop="author"><a href="/blakeembrey" class="url fn" rel="author">blakeembrey</a></span><!--
--><span class="path-divider">/</span><!--
--><strong itemprop="name"><a href="/blakeembrey/pluralize" data-pjax="#js-repo-pjax-container">pluralize</a></strong>

</h1>

  </div>
  <div class="container">
    
<nav class="reponav js-repo-nav js-sidenav-container-pjax"
     itemscope
     itemtype="http://schema.org/BreadcrumbList"
     role="navigation"
     data-pjax="#js-repo-pjax-container">

  <span itemscope itemtype="http://schema.org/ListItem" itemprop="itemListElement">
    <a href="/blakeembrey/pluralize" class="js-selected-navigation-item selected reponav-item" data-hotkey="g c" data-selected-links="repo_source repo_downloads repo_commits repo_releases repo_tags repo_branches /blakeembrey/pluralize" itemprop="url">
      <svg aria-hidden="true" class="octicon octicon-code" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M9.5 3L8 4.5 11.5 8 8 11.5 9.5 13 14 8 9.5 3zm-5 0L0 8l4.5 5L6 11.5 2.5 8 6 4.5 4.5 3z"/></svg>
      <span itemprop="name">Code</span>
      <meta itemprop="position" content="1">
</a>  </span>

    <span itemscope itemtype="http://schema.org/ListItem" itemprop="itemListElement">
      <a href="/blakeembrey/pluralize/issues" class="js-selected-navigation-item reponav-item" data-hotkey="g i" data-selected-links="repo_issues repo_labels repo_milestones /blakeembrey/pluralize/issues" itemprop="url">
        <svg aria-hidden="true" class="octicon octicon-issue-opened" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M7 2.3c3.14 0 5.7 2.56 5.7 5.7s-2.56 5.7-5.7 5.7A5.71 5.71 0 0 1 1.3 8c0-3.14 2.56-5.7 5.7-5.7zM7 1C3.14 1 0 4.14 0 8s3.14 7 7 7 7-3.14 7-7-3.14-7-7-7zm1 3H6v5h2V4zm0 6H6v2h2v-2z"/></svg>
        <span itemprop="name">Issues</span>
        <span class="counter">1</span>
        <meta itemprop="position" content="2">
</a>    </span>

  <span itemscope itemtype="http://schema.org/ListItem" itemprop="itemListElement">
    <a href="/blakeembrey/pluralize/pulls" class="js-selected-navigation-item reponav-item" data-hotkey="g p" data-selected-links="repo_pulls /blakeembrey/pluralize/pulls" itemprop="url">
      <svg aria-hidden="true" class="octicon octicon-git-pull-request" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M11 11.28V5c-.03-.78-.34-1.47-.94-2.06C9.46 2.35 8.78 2.03 8 2H7V0L4 3l3 3V4h1c.27.02.48.11.69.31.21.2.3.42.31.69v6.28A1.993 1.993 0 0 0 10 15a1.993 1.993 0 0 0 1-3.72zm-1 2.92c-.66 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2zM4 3c0-1.11-.89-2-2-2a1.993 1.993 0 0 0-1 3.72v6.56A1.993 1.993 0 0 0 2 15a1.993 1.993 0 0 0 1-3.72V4.72c.59-.34 1-.98 1-1.72zm-.8 10c0 .66-.55 1.2-1.2 1.2-.65 0-1.2-.55-1.2-1.2 0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2zM2 4.2C1.34 4.2.8 3.65.8 3c0-.65.55-1.2 1.2-1.2.65 0 1.2.55 1.2 1.2 0 .65-.55 1.2-1.2 1.2z"/></svg>
      <span itemprop="name">Pull requests</span>
      <span class="counter">0</span>
      <meta itemprop="position" content="3">
</a>  </span>

  <a href="/blakeembrey/pluralize/projects" class="js-selected-navigation-item reponav-item" data-selected-links="repo_projects new_repo_project repo_project /blakeembrey/pluralize/projects">
    <svg aria-hidden="true" class="octicon octicon-project" height="16" version="1.1" viewBox="0 0 15 16" width="15"><path fill-rule="evenodd" d="M10 12h3V2h-3v10zm-4-2h3V2H6v8zm-4 4h3V2H2v12zm-1 1h13V1H1v14zM14 0H1a1 1 0 0 0-1 1v14a1 1 0 0 0 1 1h13a1 1 0 0 0 1-1V1a1 1 0 0 0-1-1z"/></svg>
    Projects
    <span class="counter">0</span>
</a>
    <a href="/blakeembrey/pluralize/wiki" class="js-selected-navigation-item reponav-item" data-hotkey="g w" data-selected-links="repo_wiki /blakeembrey/pluralize/wiki">
      <svg aria-hidden="true" class="octicon octicon-book" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M3 5h4v1H3V5zm0 3h4V7H3v1zm0 2h4V9H3v1zm11-5h-4v1h4V5zm0 2h-4v1h4V7zm0 2h-4v1h4V9zm2-6v9c0 .55-.45 1-1 1H9.5l-1 1-1-1H2c-.55 0-1-.45-1-1V3c0-.55.45-1 1-1h5.5l1 1 1-1H15c.55 0 1 .45 1 1zm-8 .5L7.5 3H2v9h6V3.5zm7-.5H9.5l-.5.5V12h6V3z"/></svg>
      Wiki
</a>

  <a href="/blakeembrey/pluralize/pulse" class="js-selected-navigation-item reponav-item" data-selected-links="pulse /blakeembrey/pluralize/pulse">
    <svg aria-hidden="true" class="octicon octicon-pulse" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M11.5 8L8.8 5.4 6.6 8.5 5.5 1.6 2.38 8H0v2h3.6l.9-1.8.9 5.4L9 8.5l1.6 1.5H14V8z"/></svg>
    Pulse
</a>
  <a href="/blakeembrey/pluralize/graphs" class="js-selected-navigation-item reponav-item" data-selected-links="repo_graphs repo_contributors /blakeembrey/pluralize/graphs">
    <svg aria-hidden="true" class="octicon octicon-graph" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M16 14v1H0V0h1v14h15zM5 13H3V8h2v5zm4 0H7V3h2v10zm4 0h-2V6h2v7z"/></svg>
    Graphs
</a>

</nav>

  </div>
</div>

<div class="container new-discussion-timeline experiment-repo-nav">
  <div class="repository-content">

    

<a href="/blakeembrey/pluralize/blob/9b71c461921658ab8b4d5a6d93b8660b9c4efb93/pluralize.js" class="d-none js-permalink-shortcut" data-hotkey="y">Permalink</a>

<!-- blob contrib key: blob_contributors:v21:4ba183baeb02ec7d7fe4991780913e99 -->

<div class="file-navigation js-zeroclipboard-container">
  
<div class="select-menu branch-select-menu js-menu-container js-select-menu float-left">
  <button class="btn btn-sm select-menu-button js-menu-target css-truncate" data-hotkey="w"
    
    type="button" aria-label="Switch branches or tags" tabindex="0" aria-haspopup="true">
    <i>Branch:</i>
    <span class="js-select-button css-truncate-target">master</span>
  </button>

  <div class="select-menu-modal-holder js-menu-content js-navigation-container" data-pjax aria-hidden="true">

    <div class="select-menu-modal">
      <div class="select-menu-header">
        <svg aria-label="Close" class="octicon octicon-x js-menu-close" height="16" role="img" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48z"/></svg>
        <span class="select-menu-title">Switch branches/tags</span>
      </div>

      <div class="select-menu-filters">
        <div class="select-menu-text-filter">
          <input type="text" aria-label="Filter branches/tags" id="context-commitish-filter-field" class="form-control js-filterable-field js-navigation-enable" placeholder="Filter branches/tags">
        </div>
        <div class="select-menu-tabs">
          <ul>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="branches" data-filter-placeholder="Filter branches/tags" class="js-select-menu-tab" role="tab">Branches</a>
            </li>
            <li class="select-menu-tab">
              <a href="#" data-tab-filter="tags" data-filter-placeholder="Find a tag…" class="js-select-menu-tab" role="tab">Tags</a>
            </li>
          </ul>
        </div>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="branches" role="menu">

        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <a class="select-menu-item js-navigation-item js-navigation-open selected"
               href="/blakeembrey/pluralize/blob/master/pluralize.js"
               data-name="master"
               data-skip-pjax="true"
               rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target js-select-menu-filter-text">
                master
              </span>
            </a>
        </div>

          <div class="select-menu-no-results">Nothing to show</div>
      </div>

      <div class="select-menu-list select-menu-tab-bucket js-select-menu-tab-bucket" data-tab-filter="tags">
        <div data-filterable-for="context-commitish-filter-field" data-filterable-type="substring">


            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v3.1.0/pluralize.js"
              data-name="v3.1.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v3.1.0">
                v3.1.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v3.0.0/pluralize.js"
              data-name="v3.0.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v3.0.0">
                v3.0.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v2.0.0/pluralize.js"
              data-name="v2.0.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v2.0.0">
                v2.0.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.2.1/pluralize.js"
              data-name="v1.2.1"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.2.1">
                v1.2.1
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.2.0/pluralize.js"
              data-name="v1.2.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.2.0">
                v1.2.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.6/pluralize.js"
              data-name="v1.1.6"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.6">
                v1.1.6
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.5/pluralize.js"
              data-name="v1.1.5"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.5">
                v1.1.5
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.4/pluralize.js"
              data-name="v1.1.4"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.4">
                v1.1.4
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.3/pluralize.js"
              data-name="v1.1.3"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.3">
                v1.1.3
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.2/pluralize.js"
              data-name="v1.1.2"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.2">
                v1.1.2
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.1/pluralize.js"
              data-name="v1.1.1"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.1">
                v1.1.1
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.1.0/pluralize.js"
              data-name="v1.1.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.1.0">
                v1.1.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.0.3/pluralize.js"
              data-name="v1.0.3"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.0.3">
                v1.0.3
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.0.2/pluralize.js"
              data-name="v1.0.2"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.0.2">
                v1.0.2
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.0.1/pluralize.js"
              data-name="v1.0.1"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.0.1">
                v1.0.1
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v1.0.0/pluralize.js"
              data-name="v1.0.0"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v1.0.0">
                v1.0.0
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.12/pluralize.js"
              data-name="v0.0.12"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.12">
                v0.0.12
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.11/pluralize.js"
              data-name="v0.0.11"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.11">
                v0.0.11
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.10/pluralize.js"
              data-name="v0.0.10"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.10">
                v0.0.10
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.9/pluralize.js"
              data-name="v0.0.9"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.9">
                v0.0.9
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.8/pluralize.js"
              data-name="v0.0.8"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.8">
                v0.0.8
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.7/pluralize.js"
              data-name="v0.0.7"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.7">
                v0.0.7
              </span>
            </a>
            <a class="select-menu-item js-navigation-item js-navigation-open "
              href="/blakeembrey/pluralize/tree/v0.0.6/pluralize.js"
              data-name="v0.0.6"
              data-skip-pjax="true"
              rel="nofollow">
              <svg aria-hidden="true" class="octicon octicon-check select-menu-item-icon" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M12 5l-8 8-4-4 1.5-1.5L4 10l6.5-6.5z"/></svg>
              <span class="select-menu-item-text css-truncate-target" title="v0.0.6">
                v0.0.6
              </span>
            </a>
        </div>

        <div class="select-menu-no-results">Nothing to show</div>
      </div>

    </div>
  </div>
</div>

  <div class="BtnGroup float-right">
    <a href="/blakeembrey/pluralize/find/master"
          class="js-pjax-capture-input btn btn-sm BtnGroup-item"
          data-pjax
          data-hotkey="t">
      Find file
    </a>
    <button aria-label="Copy file path to clipboard" class="js-zeroclipboard btn btn-sm BtnGroup-item tooltipped tooltipped-s" data-copied-hint="Copied!" type="button">Copy path</button>
  </div>
  <div class="breadcrumb js-zeroclipboard-target">
    <span class="repo-root js-repo-root"><span class="js-path-segment"><a href="/blakeembrey/pluralize"><span>pluralize</span></a></span></span><span class="separator">/</span><strong class="final-path">pluralize.js</strong>
  </div>
</div>


  <div class="commit-tease">
      <span class="float-right">
        <a class="commit-tease-sha" href="/blakeembrey/pluralize/commit/90d82f88428f057c4b7a1d46aa38fc7c44d2d869" data-pjax>
          90d82f8
        </a>
        <relative-time datetime="2016-07-06T04:24:30Z">Jul 6, 2016</relative-time>
      </span>
      <div>
        <img alt="@blakeembrey" class="avatar" height="20" src="https://avatars0.githubusercontent.com/u/1088987?v=3&amp;s=40" width="20" />
        <a href="/blakeembrey" class="user-mention" rel="author">blakeembrey</a>
          <a href="/blakeembrey/pluralize/commit/90d82f88428f057c4b7a1d46aa38fc7c44d2d869" class="message" data-pjax="true" title="When token is an exact replace, keep casing">When token is an exact replace, keep casing</a>
      </div>

    <div class="commit-tease-contributors">
      <button type="button" class="btn-link muted-link contributors-toggle" data-facebox="#blob_contributors_box">
        <strong>7</strong>
         contributors
      </button>
          <a class="avatar-link tooltipped tooltipped-s" aria-label="blakeembrey" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=blakeembrey"><img alt="@blakeembrey" class="avatar" height="20" src="https://avatars0.githubusercontent.com/u/1088987?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="jpotts18" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=jpotts18"><img alt="@jpotts18" class="avatar" height="20" src="https://avatars0.githubusercontent.com/u/2466729?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="vladgolubev" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=vladgolubev"><img alt="@vladgolubev" class="avatar" height="20" src="https://avatars1.githubusercontent.com/u/3817380?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="naterkane" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=naterkane"><img alt="@naterkane" class="avatar" height="20" src="https://avatars2.githubusercontent.com/u/21930?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="safareli" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=safareli"><img alt="@safareli" class="avatar" height="20" src="https://avatars3.githubusercontent.com/u/1932383?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="Bockit" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=Bockit"><img alt="@Bockit" class="avatar" height="20" src="https://avatars0.githubusercontent.com/u/167362?v=3&amp;s=40" width="20" /> </a>
    <a class="avatar-link tooltipped tooltipped-s" aria-label="ajoslin" href="/blakeembrey/pluralize/commits/master/pluralize.js?author=ajoslin"><img alt="@ajoslin" class="avatar" height="20" src="https://avatars2.githubusercontent.com/u/1265995?v=3&amp;s=40" width="20" /> </a>


    </div>

    <div id="blob_contributors_box" style="display:none">
      <h2 class="facebox-header" data-facebox-id="facebox-header">Users who have contributed to this file</h2>
      <ul class="facebox-user-list" data-facebox-id="facebox-description">
          <li class="facebox-user-list-item">
            <img alt="@blakeembrey" height="24" src="https://avatars2.githubusercontent.com/u/1088987?v=3&amp;s=48" width="24" />
            <a href="/blakeembrey">blakeembrey</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@jpotts18" height="24" src="https://avatars2.githubusercontent.com/u/2466729?v=3&amp;s=48" width="24" />
            <a href="/jpotts18">jpotts18</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@vladgolubev" height="24" src="https://avatars3.githubusercontent.com/u/3817380?v=3&amp;s=48" width="24" />
            <a href="/vladgolubev">vladgolubev</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@naterkane" height="24" src="https://avatars0.githubusercontent.com/u/21930?v=3&amp;s=48" width="24" />
            <a href="/naterkane">naterkane</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@safareli" height="24" src="https://avatars1.githubusercontent.com/u/1932383?v=3&amp;s=48" width="24" />
            <a href="/safareli">safareli</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@Bockit" height="24" src="https://avatars2.githubusercontent.com/u/167362?v=3&amp;s=48" width="24" />
            <a href="/Bockit">Bockit</a>
          </li>
          <li class="facebox-user-list-item">
            <img alt="@ajoslin" height="24" src="https://avatars0.githubusercontent.com/u/1265995?v=3&amp;s=48" width="24" />
            <a href="/ajoslin">ajoslin</a>
          </li>
      </ul>
    </div>
  </div>


<div class="file">
  <div class="file-header">
  <div class="file-actions">

    <div class="BtnGroup">
      <a href="/blakeembrey/pluralize/raw/master/pluralize.js" class="btn btn-sm BtnGroup-item" id="raw-url">Raw</a>
        <a href="/blakeembrey/pluralize/blame/master/pluralize.js" class="btn btn-sm js-update-url-with-hash BtnGroup-item" data-hotkey="b">Blame</a>
      <a href="/blakeembrey/pluralize/commits/master/pluralize.js" class="btn btn-sm BtnGroup-item" rel="nofollow">History</a>
    </div>

        <a class="btn-octicon tooltipped tooltipped-nw"
           href="github-mac://openRepo/https://github.com/blakeembrey/pluralize?branch=master&amp;filepath=pluralize.js"
           aria-label="Open this file in GitHub Desktop"
           data-ga-click="Repository, open with desktop, type:mac">
            <svg aria-hidden="true" class="octicon octicon-device-desktop" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M15 2H1c-.55 0-1 .45-1 1v9c0 .55.45 1 1 1h5.34c-.25.61-.86 1.39-2.34 2h8c-1.48-.61-2.09-1.39-2.34-2H15c.55 0 1-.45 1-1V3c0-.55-.45-1-1-1zm0 9H1V3h14v8z"/></svg>
        </a>

        <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/blakeembrey/pluralize/edit/master/pluralize.js" class="inline-form js-update-url-with-hash" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="S6NFFuLlvnvuke1CBCM3TYtyrBLq1tVFOyOHCyGhu9fcBYh0/9Cx2O9pvNMm6Ri/9CQXXB2CAZlgzhkm7Sp2tQ==" /></div>
          <button class="btn-octicon tooltipped tooltipped-nw" type="submit"
            aria-label="Fork this project and edit the file" data-hotkey="e" data-disable-with>
            <svg aria-hidden="true" class="octicon octicon-pencil" height="16" version="1.1" viewBox="0 0 14 16" width="14"><path fill-rule="evenodd" d="M0 12v3h3l8-8-3-3-8 8zm3 2H1v-2h1v1h1v1zm10.3-9.3L12 6 9 3l1.3-1.3a.996.996 0 0 1 1.41 0l1.59 1.59c.39.39.39 1.02 0 1.41z"/></svg>
          </button>
</form>        <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="/blakeembrey/pluralize/delete/master/pluralize.js" class="inline-form" method="post"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /><input name="authenticity_token" type="hidden" value="fkhdOi7G1oJmQPKxsPlXgkXYko8CZxHUji9udTylwWK5Er2iXaJKMDOAVCyjsCVlyxoE1hWfh7dS7+DGHBfu1A==" /></div>
          <button class="btn-octicon btn-octicon-danger tooltipped tooltipped-nw" type="submit"
            aria-label="Fork this project and delete the file" data-disable-with>
            <svg aria-hidden="true" class="octicon octicon-trashcan" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M11 2H9c0-.55-.45-1-1-1H5c-.55 0-1 .45-1 1H2c-.55 0-1 .45-1 1v1c0 .55.45 1 1 1v9c0 .55.45 1 1 1h7c.55 0 1-.45 1-1V5c.55 0 1-.45 1-1V3c0-.55-.45-1-1-1zm-1 12H3V5h1v8h1V5h1v8h1V5h1v8h1V5h1v9zm1-10H2V3h9v1z"/></svg>
          </button>
</form>  </div>

  <div class="file-info">
      462 lines (426 sloc)
      <span class="file-info-divider"></span>
    11.3 KB
  </div>
</div>

  

  <div itemprop="text" class="blob-wrapper data type-javascript">
      <table class="highlight tab-size js-file-line-container" data-tab-size="8">
      <tr>
        <td id="L1" class="blob-num js-line-number" data-line-number="1"></td>
        <td id="LC1" class="blob-code blob-code-inner js-file-line"><span class="pl-c"><span class="pl-c">/*</span> global define <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L2" class="blob-num js-line-number" data-line-number="2"></td>
        <td id="LC2" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L3" class="blob-num js-line-number" data-line-number="3"></td>
        <td id="LC3" class="blob-code blob-code-inner js-file-line">(<span class="pl-k">function</span> (<span class="pl-smi">root</span>, <span class="pl-smi">pluralize</span>) {</td>
      </tr>
      <tr>
        <td id="L4" class="blob-num js-line-number" data-line-number="4"></td>
        <td id="LC4" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/*</span> istanbul ignore else <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L5" class="blob-num js-line-number" data-line-number="5"></td>
        <td id="LC5" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">if</span> (<span class="pl-k">typeof</span> require <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>function<span class="pl-pds">&#39;</span></span> <span class="pl-k">&amp;&amp;</span> <span class="pl-k">typeof</span> <span class="pl-c1">exports</span> <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>object<span class="pl-pds">&#39;</span></span> <span class="pl-k">&amp;&amp;</span> <span class="pl-k">typeof</span> <span class="pl-c1">module</span> <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>object<span class="pl-pds">&#39;</span></span>) {</td>
      </tr>
      <tr>
        <td id="L6" class="blob-num js-line-number" data-line-number="6"></td>
        <td id="LC6" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Node.</span></td>
      </tr>
      <tr>
        <td id="L7" class="blob-num js-line-number" data-line-number="7"></td>
        <td id="LC7" class="blob-code blob-code-inner js-file-line">    <span class="pl-c1">module</span>.<span class="pl-smi">exports</span> <span class="pl-k">=</span> <span class="pl-en">pluralize</span>();</td>
      </tr>
      <tr>
        <td id="L8" class="blob-num js-line-number" data-line-number="8"></td>
        <td id="LC8" class="blob-code blob-code-inner js-file-line">  } <span class="pl-k">else</span> <span class="pl-k">if</span> (<span class="pl-k">typeof</span> define <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>function<span class="pl-pds">&#39;</span></span> <span class="pl-k">&amp;&amp;</span> <span class="pl-smi">define</span>.<span class="pl-smi">amd</span>) {</td>
      </tr>
      <tr>
        <td id="L9" class="blob-num js-line-number" data-line-number="9"></td>
        <td id="LC9" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> AMD, registers as an anonymous module.</span></td>
      </tr>
      <tr>
        <td id="L10" class="blob-num js-line-number" data-line-number="10"></td>
        <td id="LC10" class="blob-code blob-code-inner js-file-line">    <span class="pl-en">define</span>(<span class="pl-k">function</span> () {</td>
      </tr>
      <tr>
        <td id="L11" class="blob-num js-line-number" data-line-number="11"></td>
        <td id="LC11" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> <span class="pl-en">pluralize</span>();</td>
      </tr>
      <tr>
        <td id="L12" class="blob-num js-line-number" data-line-number="12"></td>
        <td id="LC12" class="blob-code blob-code-inner js-file-line">    });</td>
      </tr>
      <tr>
        <td id="L13" class="blob-num js-line-number" data-line-number="13"></td>
        <td id="LC13" class="blob-code blob-code-inner js-file-line">  } <span class="pl-k">else</span> {</td>
      </tr>
      <tr>
        <td id="L14" class="blob-num js-line-number" data-line-number="14"></td>
        <td id="LC14" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Browser global.</span></td>
      </tr>
      <tr>
        <td id="L15" class="blob-num js-line-number" data-line-number="15"></td>
        <td id="LC15" class="blob-code blob-code-inner js-file-line">    <span class="pl-smi">root</span>.<span class="pl-smi">pluralize</span> <span class="pl-k">=</span> <span class="pl-en">pluralize</span>();</td>
      </tr>
      <tr>
        <td id="L16" class="blob-num js-line-number" data-line-number="16"></td>
        <td id="LC16" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L17" class="blob-num js-line-number" data-line-number="17"></td>
        <td id="LC17" class="blob-code blob-code-inner js-file-line">})(<span class="pl-c1">this</span>, <span class="pl-k">function</span> () {</td>
      </tr>
      <tr>
        <td id="L18" class="blob-num js-line-number" data-line-number="18"></td>
        <td id="LC18" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">//</span> Rule storage - pluralize and singularize need to be run sequentially,</span></td>
      </tr>
      <tr>
        <td id="L19" class="blob-num js-line-number" data-line-number="19"></td>
        <td id="LC19" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">//</span> while other rules can be optimized using an object for instant lookups.</span></td>
      </tr>
      <tr>
        <td id="L20" class="blob-num js-line-number" data-line-number="20"></td>
        <td id="LC20" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">var</span> pluralRules <span class="pl-k">=</span> [];</td>
      </tr>
      <tr>
        <td id="L21" class="blob-num js-line-number" data-line-number="21"></td>
        <td id="LC21" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">var</span> singularRules <span class="pl-k">=</span> [];</td>
      </tr>
      <tr>
        <td id="L22" class="blob-num js-line-number" data-line-number="22"></td>
        <td id="LC22" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">var</span> uncountables <span class="pl-k">=</span> {};</td>
      </tr>
      <tr>
        <td id="L23" class="blob-num js-line-number" data-line-number="23"></td>
        <td id="LC23" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">var</span> irregularPlurals <span class="pl-k">=</span> {};</td>
      </tr>
      <tr>
        <td id="L24" class="blob-num js-line-number" data-line-number="24"></td>
        <td id="LC24" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">var</span> irregularSingles <span class="pl-k">=</span> {};</td>
      </tr>
      <tr>
        <td id="L25" class="blob-num js-line-number" data-line-number="25"></td>
        <td id="LC25" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L26" class="blob-num js-line-number" data-line-number="26"></td>
        <td id="LC26" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L27" class="blob-num js-line-number" data-line-number="27"></td>
        <td id="LC27" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Title case a string.</span></td>
      </tr>
      <tr>
        <td id="L28" class="blob-num js-line-number" data-line-number="28"></td>
        <td id="LC28" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L29" class="blob-num js-line-number" data-line-number="29"></td>
        <td id="LC29" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span> <span class="pl-smi">str</span></span></td>
      </tr>
      <tr>
        <td id="L30" class="blob-num js-line-number" data-line-number="30"></td>
        <td id="LC30" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{string}</span></span></td>
      </tr>
      <tr>
        <td id="L31" class="blob-num js-line-number" data-line-number="31"></td>
        <td id="LC31" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L32" class="blob-num js-line-number" data-line-number="32"></td>
        <td id="LC32" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">toTitleCase</span> (<span class="pl-smi">str</span>) {</td>
      </tr>
      <tr>
        <td id="L33" class="blob-num js-line-number" data-line-number="33"></td>
        <td id="LC33" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">str</span>.<span class="pl-c1">charAt</span>(<span class="pl-c1">0</span>).<span class="pl-c1">toUpperCase</span>() <span class="pl-k">+</span> <span class="pl-smi">str</span>.<span class="pl-c1">substr</span>(<span class="pl-c1">1</span>).<span class="pl-c1">toLowerCase</span>();</td>
      </tr>
      <tr>
        <td id="L34" class="blob-num js-line-number" data-line-number="34"></td>
        <td id="LC34" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L35" class="blob-num js-line-number" data-line-number="35"></td>
        <td id="LC35" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L36" class="blob-num js-line-number" data-line-number="36"></td>
        <td id="LC36" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L37" class="blob-num js-line-number" data-line-number="37"></td>
        <td id="LC37" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Sanitize a pluralization rule to a usable regular expression.</span></td>
      </tr>
      <tr>
        <td id="L38" class="blob-num js-line-number" data-line-number="38"></td>
        <td id="LC38" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L39" class="blob-num js-line-number" data-line-number="39"></td>
        <td id="LC39" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{(RegExp|string)}</span> <span class="pl-smi">rule</span></span></td>
      </tr>
      <tr>
        <td id="L40" class="blob-num js-line-number" data-line-number="40"></td>
        <td id="LC40" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{RegExp}</span></span></td>
      </tr>
      <tr>
        <td id="L41" class="blob-num js-line-number" data-line-number="41"></td>
        <td id="LC41" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L42" class="blob-num js-line-number" data-line-number="42"></td>
        <td id="LC42" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">sanitizeRule</span> (<span class="pl-smi">rule</span>) {</td>
      </tr>
      <tr>
        <td id="L43" class="blob-num js-line-number" data-line-number="43"></td>
        <td id="LC43" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (<span class="pl-k">typeof</span> rule <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>string<span class="pl-pds">&#39;</span></span>) {</td>
      </tr>
      <tr>
        <td id="L44" class="blob-num js-line-number" data-line-number="44"></td>
        <td id="LC44" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> <span class="pl-k">new</span> <span class="pl-en">RegExp</span>(<span class="pl-s"><span class="pl-pds">&#39;</span>^<span class="pl-pds">&#39;</span></span> <span class="pl-k">+</span> rule <span class="pl-k">+</span> <span class="pl-s"><span class="pl-pds">&#39;</span>$<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>i<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L45" class="blob-num js-line-number" data-line-number="45"></td>
        <td id="LC45" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L46" class="blob-num js-line-number" data-line-number="46"></td>
        <td id="LC46" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L47" class="blob-num js-line-number" data-line-number="47"></td>
        <td id="LC47" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> rule;</td>
      </tr>
      <tr>
        <td id="L48" class="blob-num js-line-number" data-line-number="48"></td>
        <td id="LC48" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L49" class="blob-num js-line-number" data-line-number="49"></td>
        <td id="LC49" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L50" class="blob-num js-line-number" data-line-number="50"></td>
        <td id="LC50" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L51" class="blob-num js-line-number" data-line-number="51"></td>
        <td id="LC51" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Pass in a word token to produce a function that can replicate the case on</span></td>
      </tr>
      <tr>
        <td id="L52" class="blob-num js-line-number" data-line-number="52"></td>
        <td id="LC52" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * another word.</span></td>
      </tr>
      <tr>
        <td id="L53" class="blob-num js-line-number" data-line-number="53"></td>
        <td id="LC53" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L54" class="blob-num js-line-number" data-line-number="54"></td>
        <td id="LC54" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span>   <span class="pl-smi">word</span></span></td>
      </tr>
      <tr>
        <td id="L55" class="blob-num js-line-number" data-line-number="55"></td>
        <td id="LC55" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span>   <span class="pl-smi">token</span></span></td>
      </tr>
      <tr>
        <td id="L56" class="blob-num js-line-number" data-line-number="56"></td>
        <td id="LC56" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{Function}</span></span></td>
      </tr>
      <tr>
        <td id="L57" class="blob-num js-line-number" data-line-number="57"></td>
        <td id="LC57" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L58" class="blob-num js-line-number" data-line-number="58"></td>
        <td id="LC58" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">restoreCase</span> (<span class="pl-smi">word</span>, <span class="pl-smi">token</span>) {</td>
      </tr>
      <tr>
        <td id="L59" class="blob-num js-line-number" data-line-number="59"></td>
        <td id="LC59" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Tokens are an exact match.</span></td>
      </tr>
      <tr>
        <td id="L60" class="blob-num js-line-number" data-line-number="60"></td>
        <td id="LC60" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (word <span class="pl-k">===</span> token) {</td>
      </tr>
      <tr>
        <td id="L61" class="blob-num js-line-number" data-line-number="61"></td>
        <td id="LC61" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> token;</td>
      </tr>
      <tr>
        <td id="L62" class="blob-num js-line-number" data-line-number="62"></td>
        <td id="LC62" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L63" class="blob-num js-line-number" data-line-number="63"></td>
        <td id="LC63" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L64" class="blob-num js-line-number" data-line-number="64"></td>
        <td id="LC64" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Upper cased words. E.g. &quot;HELLO&quot;.</span></td>
      </tr>
      <tr>
        <td id="L65" class="blob-num js-line-number" data-line-number="65"></td>
        <td id="LC65" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (word <span class="pl-k">===</span> <span class="pl-smi">word</span>.<span class="pl-c1">toUpperCase</span>()) {</td>
      </tr>
      <tr>
        <td id="L66" class="blob-num js-line-number" data-line-number="66"></td>
        <td id="LC66" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> <span class="pl-smi">token</span>.<span class="pl-c1">toUpperCase</span>();</td>
      </tr>
      <tr>
        <td id="L67" class="blob-num js-line-number" data-line-number="67"></td>
        <td id="LC67" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L68" class="blob-num js-line-number" data-line-number="68"></td>
        <td id="LC68" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L69" class="blob-num js-line-number" data-line-number="69"></td>
        <td id="LC69" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Title cased words. E.g. &quot;Title&quot;.</span></td>
      </tr>
      <tr>
        <td id="L70" class="blob-num js-line-number" data-line-number="70"></td>
        <td id="LC70" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (word[<span class="pl-c1">0</span>] <span class="pl-k">===</span> word[<span class="pl-c1">0</span>].<span class="pl-c1">toUpperCase</span>()) {</td>
      </tr>
      <tr>
        <td id="L71" class="blob-num js-line-number" data-line-number="71"></td>
        <td id="LC71" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> <span class="pl-en">toTitleCase</span>(token);</td>
      </tr>
      <tr>
        <td id="L72" class="blob-num js-line-number" data-line-number="72"></td>
        <td id="LC72" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L73" class="blob-num js-line-number" data-line-number="73"></td>
        <td id="LC73" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L74" class="blob-num js-line-number" data-line-number="74"></td>
        <td id="LC74" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Lower cased words. E.g. &quot;test&quot;.</span></td>
      </tr>
      <tr>
        <td id="L75" class="blob-num js-line-number" data-line-number="75"></td>
        <td id="LC75" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">token</span>.<span class="pl-c1">toLowerCase</span>();</td>
      </tr>
      <tr>
        <td id="L76" class="blob-num js-line-number" data-line-number="76"></td>
        <td id="LC76" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L77" class="blob-num js-line-number" data-line-number="77"></td>
        <td id="LC77" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L78" class="blob-num js-line-number" data-line-number="78"></td>
        <td id="LC78" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L79" class="blob-num js-line-number" data-line-number="79"></td>
        <td id="LC79" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Interpolate a regexp string.</span></td>
      </tr>
      <tr>
        <td id="L80" class="blob-num js-line-number" data-line-number="80"></td>
        <td id="LC80" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L81" class="blob-num js-line-number" data-line-number="81"></td>
        <td id="LC81" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span> <span class="pl-smi">str</span></span></td>
      </tr>
      <tr>
        <td id="L82" class="blob-num js-line-number" data-line-number="82"></td>
        <td id="LC82" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{Array}</span>  <span class="pl-smi">args</span></span></td>
      </tr>
      <tr>
        <td id="L83" class="blob-num js-line-number" data-line-number="83"></td>
        <td id="LC83" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{string}</span></span></td>
      </tr>
      <tr>
        <td id="L84" class="blob-num js-line-number" data-line-number="84"></td>
        <td id="LC84" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L85" class="blob-num js-line-number" data-line-number="85"></td>
        <td id="LC85" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">interpolate</span> (<span class="pl-smi">str</span>, <span class="pl-smi">args</span>) {</td>
      </tr>
      <tr>
        <td id="L86" class="blob-num js-line-number" data-line-number="86"></td>
        <td id="LC86" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">str</span>.<span class="pl-c1">replace</span>(<span class="pl-sr"><span class="pl-pds">/</span><span class="pl-cce">\$</span>(<span class="pl-c1">\d</span><span class="pl-k">{1,2}</span>)<span class="pl-pds">/</span>g</span>, <span class="pl-k">function</span> (<span class="pl-smi">match</span>, <span class="pl-smi">index</span>) {</td>
      </tr>
      <tr>
        <td id="L87" class="blob-num js-line-number" data-line-number="87"></td>
        <td id="LC87" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> args[index] <span class="pl-k">||</span> <span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>;</td>
      </tr>
      <tr>
        <td id="L88" class="blob-num js-line-number" data-line-number="88"></td>
        <td id="LC88" class="blob-code blob-code-inner js-file-line">    });</td>
      </tr>
      <tr>
        <td id="L89" class="blob-num js-line-number" data-line-number="89"></td>
        <td id="LC89" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L90" class="blob-num js-line-number" data-line-number="90"></td>
        <td id="LC90" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L91" class="blob-num js-line-number" data-line-number="91"></td>
        <td id="LC91" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L92" class="blob-num js-line-number" data-line-number="92"></td>
        <td id="LC92" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Sanitize a word by passing in the word and sanitization rules.</span></td>
      </tr>
      <tr>
        <td id="L93" class="blob-num js-line-number" data-line-number="93"></td>
        <td id="LC93" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L94" class="blob-num js-line-number" data-line-number="94"></td>
        <td id="LC94" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span>   <span class="pl-smi">token</span></span></td>
      </tr>
      <tr>
        <td id="L95" class="blob-num js-line-number" data-line-number="95"></td>
        <td id="LC95" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span>   <span class="pl-smi">word</span></span></td>
      </tr>
      <tr>
        <td id="L96" class="blob-num js-line-number" data-line-number="96"></td>
        <td id="LC96" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{Array}</span>    <span class="pl-smi">collection</span></span></td>
      </tr>
      <tr>
        <td id="L97" class="blob-num js-line-number" data-line-number="97"></td>
        <td id="LC97" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{string}</span></span></td>
      </tr>
      <tr>
        <td id="L98" class="blob-num js-line-number" data-line-number="98"></td>
        <td id="LC98" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L99" class="blob-num js-line-number" data-line-number="99"></td>
        <td id="LC99" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">sanitizeWord</span> (<span class="pl-smi">token</span>, <span class="pl-smi">word</span>, <span class="pl-smi">collection</span>) {</td>
      </tr>
      <tr>
        <td id="L100" class="blob-num js-line-number" data-line-number="100"></td>
        <td id="LC100" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Empty string or doesn&#39;t need fixing.</span></td>
      </tr>
      <tr>
        <td id="L101" class="blob-num js-line-number" data-line-number="101"></td>
        <td id="LC101" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (<span class="pl-k">!</span><span class="pl-smi">token</span>.<span class="pl-c1">length</span> <span class="pl-k">||</span> <span class="pl-smi">uncountables</span>.<span class="pl-en">hasOwnProperty</span>(token)) {</td>
      </tr>
      <tr>
        <td id="L102" class="blob-num js-line-number" data-line-number="102"></td>
        <td id="LC102" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> word;</td>
      </tr>
      <tr>
        <td id="L103" class="blob-num js-line-number" data-line-number="103"></td>
        <td id="LC103" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L104" class="blob-num js-line-number" data-line-number="104"></td>
        <td id="LC104" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L105" class="blob-num js-line-number" data-line-number="105"></td>
        <td id="LC105" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">var</span> len <span class="pl-k">=</span> <span class="pl-smi">collection</span>.<span class="pl-c1">length</span>;</td>
      </tr>
      <tr>
        <td id="L106" class="blob-num js-line-number" data-line-number="106"></td>
        <td id="LC106" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L107" class="blob-num js-line-number" data-line-number="107"></td>
        <td id="LC107" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Iterate over the sanitization rules and use the first one to match.</span></td>
      </tr>
      <tr>
        <td id="L108" class="blob-num js-line-number" data-line-number="108"></td>
        <td id="LC108" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">while</span> (len<span class="pl-k">--</span>) {</td>
      </tr>
      <tr>
        <td id="L109" class="blob-num js-line-number" data-line-number="109"></td>
        <td id="LC109" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">var</span> rule <span class="pl-k">=</span> collection[len];</td>
      </tr>
      <tr>
        <td id="L110" class="blob-num js-line-number" data-line-number="110"></td>
        <td id="LC110" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L111" class="blob-num js-line-number" data-line-number="111"></td>
        <td id="LC111" class="blob-code blob-code-inner js-file-line">      <span class="pl-c"><span class="pl-c">//</span> If the rule passes, return the replacement.</span></td>
      </tr>
      <tr>
        <td id="L112" class="blob-num js-line-number" data-line-number="112"></td>
        <td id="LC112" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">if</span> (rule[<span class="pl-c1">0</span>].<span class="pl-c1">test</span>(word)) {</td>
      </tr>
      <tr>
        <td id="L113" class="blob-num js-line-number" data-line-number="113"></td>
        <td id="LC113" class="blob-code blob-code-inner js-file-line">        <span class="pl-k">return</span> <span class="pl-smi">word</span>.<span class="pl-c1">replace</span>(rule[<span class="pl-c1">0</span>], <span class="pl-k">function</span> (<span class="pl-smi">match</span>, <span class="pl-smi">index</span>, <span class="pl-smi">word</span>) {</td>
      </tr>
      <tr>
        <td id="L114" class="blob-num js-line-number" data-line-number="114"></td>
        <td id="LC114" class="blob-code blob-code-inner js-file-line">          <span class="pl-k">var</span> result <span class="pl-k">=</span> <span class="pl-en">interpolate</span>(rule[<span class="pl-c1">1</span>], <span class="pl-c1">arguments</span>);</td>
      </tr>
      <tr>
        <td id="L115" class="blob-num js-line-number" data-line-number="115"></td>
        <td id="LC115" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L116" class="blob-num js-line-number" data-line-number="116"></td>
        <td id="LC116" class="blob-code blob-code-inner js-file-line">          <span class="pl-k">if</span> (match <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>) {</td>
      </tr>
      <tr>
        <td id="L117" class="blob-num js-line-number" data-line-number="117"></td>
        <td id="LC117" class="blob-code blob-code-inner js-file-line">            <span class="pl-k">return</span> <span class="pl-en">restoreCase</span>(word[index <span class="pl-k">-</span> <span class="pl-c1">1</span>], result);</td>
      </tr>
      <tr>
        <td id="L118" class="blob-num js-line-number" data-line-number="118"></td>
        <td id="LC118" class="blob-code blob-code-inner js-file-line">          }</td>
      </tr>
      <tr>
        <td id="L119" class="blob-num js-line-number" data-line-number="119"></td>
        <td id="LC119" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L120" class="blob-num js-line-number" data-line-number="120"></td>
        <td id="LC120" class="blob-code blob-code-inner js-file-line">          <span class="pl-k">return</span> <span class="pl-en">restoreCase</span>(match, result);</td>
      </tr>
      <tr>
        <td id="L121" class="blob-num js-line-number" data-line-number="121"></td>
        <td id="LC121" class="blob-code blob-code-inner js-file-line">        });</td>
      </tr>
      <tr>
        <td id="L122" class="blob-num js-line-number" data-line-number="122"></td>
        <td id="LC122" class="blob-code blob-code-inner js-file-line">      }</td>
      </tr>
      <tr>
        <td id="L123" class="blob-num js-line-number" data-line-number="123"></td>
        <td id="LC123" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L124" class="blob-num js-line-number" data-line-number="124"></td>
        <td id="LC124" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L125" class="blob-num js-line-number" data-line-number="125"></td>
        <td id="LC125" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> word;</td>
      </tr>
      <tr>
        <td id="L126" class="blob-num js-line-number" data-line-number="126"></td>
        <td id="LC126" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L127" class="blob-num js-line-number" data-line-number="127"></td>
        <td id="LC127" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L128" class="blob-num js-line-number" data-line-number="128"></td>
        <td id="LC128" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L129" class="blob-num js-line-number" data-line-number="129"></td>
        <td id="LC129" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Replace a word with the updated word.</span></td>
      </tr>
      <tr>
        <td id="L130" class="blob-num js-line-number" data-line-number="130"></td>
        <td id="LC130" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L131" class="blob-num js-line-number" data-line-number="131"></td>
        <td id="LC131" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{Object}</span>   <span class="pl-smi">replaceMap</span></span></td>
      </tr>
      <tr>
        <td id="L132" class="blob-num js-line-number" data-line-number="132"></td>
        <td id="LC132" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{Object}</span>   <span class="pl-smi">keepMap</span></span></td>
      </tr>
      <tr>
        <td id="L133" class="blob-num js-line-number" data-line-number="133"></td>
        <td id="LC133" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{Array}</span>    <span class="pl-smi">rules</span></span></td>
      </tr>
      <tr>
        <td id="L134" class="blob-num js-line-number" data-line-number="134"></td>
        <td id="LC134" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{Function}</span></span></td>
      </tr>
      <tr>
        <td id="L135" class="blob-num js-line-number" data-line-number="135"></td>
        <td id="LC135" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L136" class="blob-num js-line-number" data-line-number="136"></td>
        <td id="LC136" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">replaceWord</span> (<span class="pl-smi">replaceMap</span>, <span class="pl-smi">keepMap</span>, <span class="pl-smi">rules</span>) {</td>
      </tr>
      <tr>
        <td id="L137" class="blob-num js-line-number" data-line-number="137"></td>
        <td id="LC137" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-k">function</span> (<span class="pl-smi">word</span>) {</td>
      </tr>
      <tr>
        <td id="L138" class="blob-num js-line-number" data-line-number="138"></td>
        <td id="LC138" class="blob-code blob-code-inner js-file-line">      <span class="pl-c"><span class="pl-c">//</span> Get the correct token and case restoration functions.</span></td>
      </tr>
      <tr>
        <td id="L139" class="blob-num js-line-number" data-line-number="139"></td>
        <td id="LC139" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">var</span> token <span class="pl-k">=</span> <span class="pl-smi">word</span>.<span class="pl-c1">toLowerCase</span>();</td>
      </tr>
      <tr>
        <td id="L140" class="blob-num js-line-number" data-line-number="140"></td>
        <td id="LC140" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L141" class="blob-num js-line-number" data-line-number="141"></td>
        <td id="LC141" class="blob-code blob-code-inner js-file-line">      <span class="pl-c"><span class="pl-c">//</span> Check against the keep object map.</span></td>
      </tr>
      <tr>
        <td id="L142" class="blob-num js-line-number" data-line-number="142"></td>
        <td id="LC142" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">if</span> (<span class="pl-smi">keepMap</span>.<span class="pl-en">hasOwnProperty</span>(token)) {</td>
      </tr>
      <tr>
        <td id="L143" class="blob-num js-line-number" data-line-number="143"></td>
        <td id="LC143" class="blob-code blob-code-inner js-file-line">        <span class="pl-k">return</span> <span class="pl-en">restoreCase</span>(word, token);</td>
      </tr>
      <tr>
        <td id="L144" class="blob-num js-line-number" data-line-number="144"></td>
        <td id="LC144" class="blob-code blob-code-inner js-file-line">      }</td>
      </tr>
      <tr>
        <td id="L145" class="blob-num js-line-number" data-line-number="145"></td>
        <td id="LC145" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L146" class="blob-num js-line-number" data-line-number="146"></td>
        <td id="LC146" class="blob-code blob-code-inner js-file-line">      <span class="pl-c"><span class="pl-c">//</span> Check against the replacement map for a direct word replacement.</span></td>
      </tr>
      <tr>
        <td id="L147" class="blob-num js-line-number" data-line-number="147"></td>
        <td id="LC147" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">if</span> (<span class="pl-smi">replaceMap</span>.<span class="pl-en">hasOwnProperty</span>(token)) {</td>
      </tr>
      <tr>
        <td id="L148" class="blob-num js-line-number" data-line-number="148"></td>
        <td id="LC148" class="blob-code blob-code-inner js-file-line">        <span class="pl-k">return</span> <span class="pl-en">restoreCase</span>(word, replaceMap[token]);</td>
      </tr>
      <tr>
        <td id="L149" class="blob-num js-line-number" data-line-number="149"></td>
        <td id="LC149" class="blob-code blob-code-inner js-file-line">      }</td>
      </tr>
      <tr>
        <td id="L150" class="blob-num js-line-number" data-line-number="150"></td>
        <td id="LC150" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L151" class="blob-num js-line-number" data-line-number="151"></td>
        <td id="LC151" class="blob-code blob-code-inner js-file-line">      <span class="pl-c"><span class="pl-c">//</span> Run all the rules against the word.</span></td>
      </tr>
      <tr>
        <td id="L152" class="blob-num js-line-number" data-line-number="152"></td>
        <td id="LC152" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span> <span class="pl-en">sanitizeWord</span>(token, word, rules);</td>
      </tr>
      <tr>
        <td id="L153" class="blob-num js-line-number" data-line-number="153"></td>
        <td id="LC153" class="blob-code blob-code-inner js-file-line">    };</td>
      </tr>
      <tr>
        <td id="L154" class="blob-num js-line-number" data-line-number="154"></td>
        <td id="LC154" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L155" class="blob-num js-line-number" data-line-number="155"></td>
        <td id="LC155" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L156" class="blob-num js-line-number" data-line-number="156"></td>
        <td id="LC156" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L157" class="blob-num js-line-number" data-line-number="157"></td>
        <td id="LC157" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Pluralize or singularize a word based on the passed in count.</span></td>
      </tr>
      <tr>
        <td id="L158" class="blob-num js-line-number" data-line-number="158"></td>
        <td id="LC158" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L159" class="blob-num js-line-number" data-line-number="159"></td>
        <td id="LC159" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{string}</span>  <span class="pl-smi">word</span></span></td>
      </tr>
      <tr>
        <td id="L160" class="blob-num js-line-number" data-line-number="160"></td>
        <td id="LC160" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{number}</span>  <span class="pl-smi">count</span></span></td>
      </tr>
      <tr>
        <td id="L161" class="blob-num js-line-number" data-line-number="161"></td>
        <td id="LC161" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span>  <span class="pl-en">{boolean}</span> <span class="pl-smi">inclusive</span></span></td>
      </tr>
      <tr>
        <td id="L162" class="blob-num js-line-number" data-line-number="162"></td>
        <td id="LC162" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@return</span> <span class="pl-en">{string}</span></span></td>
      </tr>
      <tr>
        <td id="L163" class="blob-num js-line-number" data-line-number="163"></td>
        <td id="LC163" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L164" class="blob-num js-line-number" data-line-number="164"></td>
        <td id="LC164" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">function</span> <span class="pl-en">pluralize</span> (<span class="pl-smi">word</span>, <span class="pl-smi">count</span>, <span class="pl-smi">inclusive</span>) {</td>
      </tr>
      <tr>
        <td id="L165" class="blob-num js-line-number" data-line-number="165"></td>
        <td id="LC165" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">var</span> pluralized <span class="pl-k">=</span> count <span class="pl-k">===</span> <span class="pl-c1">1</span></td>
      </tr>
      <tr>
        <td id="L166" class="blob-num js-line-number" data-line-number="166"></td>
        <td id="LC166" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">?</span> <span class="pl-smi">pluralize</span>.<span class="pl-en">singular</span>(word) <span class="pl-k">:</span> <span class="pl-smi">pluralize</span>.<span class="pl-en">plural</span>(word);</td>
      </tr>
      <tr>
        <td id="L167" class="blob-num js-line-number" data-line-number="167"></td>
        <td id="LC167" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L168" class="blob-num js-line-number" data-line-number="168"></td>
        <td id="LC168" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> (inclusive <span class="pl-k">?</span> count <span class="pl-k">+</span> <span class="pl-s"><span class="pl-pds">&#39;</span> <span class="pl-pds">&#39;</span></span> <span class="pl-k">:</span> <span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>) <span class="pl-k">+</span> pluralized;</td>
      </tr>
      <tr>
        <td id="L169" class="blob-num js-line-number" data-line-number="169"></td>
        <td id="LC169" class="blob-code blob-code-inner js-file-line">  }</td>
      </tr>
      <tr>
        <td id="L170" class="blob-num js-line-number" data-line-number="170"></td>
        <td id="LC170" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L171" class="blob-num js-line-number" data-line-number="171"></td>
        <td id="LC171" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L172" class="blob-num js-line-number" data-line-number="172"></td>
        <td id="LC172" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Pluralize a word.</span></td>
      </tr>
      <tr>
        <td id="L173" class="blob-num js-line-number" data-line-number="173"></td>
        <td id="LC173" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L174" class="blob-num js-line-number" data-line-number="174"></td>
        <td id="LC174" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@type</span> <span class="pl-en">{Function}</span></span></td>
      </tr>
      <tr>
        <td id="L175" class="blob-num js-line-number" data-line-number="175"></td>
        <td id="LC175" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L176" class="blob-num js-line-number" data-line-number="176"></td>
        <td id="LC176" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-smi">plural</span> <span class="pl-k">=</span> <span class="pl-en">replaceWord</span>(</td>
      </tr>
      <tr>
        <td id="L177" class="blob-num js-line-number" data-line-number="177"></td>
        <td id="LC177" class="blob-code blob-code-inner js-file-line">    irregularSingles, irregularPlurals, pluralRules</td>
      </tr>
      <tr>
        <td id="L178" class="blob-num js-line-number" data-line-number="178"></td>
        <td id="LC178" class="blob-code blob-code-inner js-file-line">  );</td>
      </tr>
      <tr>
        <td id="L179" class="blob-num js-line-number" data-line-number="179"></td>
        <td id="LC179" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L180" class="blob-num js-line-number" data-line-number="180"></td>
        <td id="LC180" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L181" class="blob-num js-line-number" data-line-number="181"></td>
        <td id="LC181" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Singularize a word.</span></td>
      </tr>
      <tr>
        <td id="L182" class="blob-num js-line-number" data-line-number="182"></td>
        <td id="LC182" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L183" class="blob-num js-line-number" data-line-number="183"></td>
        <td id="LC183" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@type</span> <span class="pl-en">{Function}</span></span></td>
      </tr>
      <tr>
        <td id="L184" class="blob-num js-line-number" data-line-number="184"></td>
        <td id="LC184" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L185" class="blob-num js-line-number" data-line-number="185"></td>
        <td id="LC185" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-smi">singular</span> <span class="pl-k">=</span> <span class="pl-en">replaceWord</span>(</td>
      </tr>
      <tr>
        <td id="L186" class="blob-num js-line-number" data-line-number="186"></td>
        <td id="LC186" class="blob-code blob-code-inner js-file-line">    irregularPlurals, irregularSingles, singularRules</td>
      </tr>
      <tr>
        <td id="L187" class="blob-num js-line-number" data-line-number="187"></td>
        <td id="LC187" class="blob-code blob-code-inner js-file-line">  );</td>
      </tr>
      <tr>
        <td id="L188" class="blob-num js-line-number" data-line-number="188"></td>
        <td id="LC188" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L189" class="blob-num js-line-number" data-line-number="189"></td>
        <td id="LC189" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L190" class="blob-num js-line-number" data-line-number="190"></td>
        <td id="LC190" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Add a pluralization rule to the collection.</span></td>
      </tr>
      <tr>
        <td id="L191" class="blob-num js-line-number" data-line-number="191"></td>
        <td id="LC191" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L192" class="blob-num js-line-number" data-line-number="192"></td>
        <td id="LC192" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{(string|RegExp)}</span> <span class="pl-smi">rule</span></span></td>
      </tr>
      <tr>
        <td id="L193" class="blob-num js-line-number" data-line-number="193"></td>
        <td id="LC193" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{string}</span>          <span class="pl-smi">replacement</span></span></td>
      </tr>
      <tr>
        <td id="L194" class="blob-num js-line-number" data-line-number="194"></td>
        <td id="LC194" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L195" class="blob-num js-line-number" data-line-number="195"></td>
        <td id="LC195" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-en">addPluralRule</span> <span class="pl-k">=</span> <span class="pl-k">function</span> (<span class="pl-smi">rule</span>, <span class="pl-smi">replacement</span>) {</td>
      </tr>
      <tr>
        <td id="L196" class="blob-num js-line-number" data-line-number="196"></td>
        <td id="LC196" class="blob-code blob-code-inner js-file-line">    <span class="pl-smi">pluralRules</span>.<span class="pl-c1">push</span>([<span class="pl-en">sanitizeRule</span>(rule), replacement]);</td>
      </tr>
      <tr>
        <td id="L197" class="blob-num js-line-number" data-line-number="197"></td>
        <td id="LC197" class="blob-code blob-code-inner js-file-line">  };</td>
      </tr>
      <tr>
        <td id="L198" class="blob-num js-line-number" data-line-number="198"></td>
        <td id="LC198" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L199" class="blob-num js-line-number" data-line-number="199"></td>
        <td id="LC199" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L200" class="blob-num js-line-number" data-line-number="200"></td>
        <td id="LC200" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Add a singularization rule to the collection.</span></td>
      </tr>
      <tr>
        <td id="L201" class="blob-num js-line-number" data-line-number="201"></td>
        <td id="LC201" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L202" class="blob-num js-line-number" data-line-number="202"></td>
        <td id="LC202" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{(string|RegExp)}</span> <span class="pl-smi">rule</span></span></td>
      </tr>
      <tr>
        <td id="L203" class="blob-num js-line-number" data-line-number="203"></td>
        <td id="LC203" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{string}</span>          <span class="pl-smi">replacement</span></span></td>
      </tr>
      <tr>
        <td id="L204" class="blob-num js-line-number" data-line-number="204"></td>
        <td id="LC204" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L205" class="blob-num js-line-number" data-line-number="205"></td>
        <td id="LC205" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-en">addSingularRule</span> <span class="pl-k">=</span> <span class="pl-k">function</span> (<span class="pl-smi">rule</span>, <span class="pl-smi">replacement</span>) {</td>
      </tr>
      <tr>
        <td id="L206" class="blob-num js-line-number" data-line-number="206"></td>
        <td id="LC206" class="blob-code blob-code-inner js-file-line">    <span class="pl-smi">singularRules</span>.<span class="pl-c1">push</span>([<span class="pl-en">sanitizeRule</span>(rule), replacement]);</td>
      </tr>
      <tr>
        <td id="L207" class="blob-num js-line-number" data-line-number="207"></td>
        <td id="LC207" class="blob-code blob-code-inner js-file-line">  };</td>
      </tr>
      <tr>
        <td id="L208" class="blob-num js-line-number" data-line-number="208"></td>
        <td id="LC208" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L209" class="blob-num js-line-number" data-line-number="209"></td>
        <td id="LC209" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L210" class="blob-num js-line-number" data-line-number="210"></td>
        <td id="LC210" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Add an uncountable word rule.</span></td>
      </tr>
      <tr>
        <td id="L211" class="blob-num js-line-number" data-line-number="211"></td>
        <td id="LC211" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L212" class="blob-num js-line-number" data-line-number="212"></td>
        <td id="LC212" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{(string|RegExp)}</span> <span class="pl-smi">word</span></span></td>
      </tr>
      <tr>
        <td id="L213" class="blob-num js-line-number" data-line-number="213"></td>
        <td id="LC213" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L214" class="blob-num js-line-number" data-line-number="214"></td>
        <td id="LC214" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-en">addUncountableRule</span> <span class="pl-k">=</span> <span class="pl-k">function</span> (<span class="pl-smi">word</span>) {</td>
      </tr>
      <tr>
        <td id="L215" class="blob-num js-line-number" data-line-number="215"></td>
        <td id="LC215" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">if</span> (<span class="pl-k">typeof</span> word <span class="pl-k">===</span> <span class="pl-s"><span class="pl-pds">&#39;</span>string<span class="pl-pds">&#39;</span></span>) {</td>
      </tr>
      <tr>
        <td id="L216" class="blob-num js-line-number" data-line-number="216"></td>
        <td id="LC216" class="blob-code blob-code-inner js-file-line">      uncountables[<span class="pl-smi">word</span>.<span class="pl-c1">toLowerCase</span>()] <span class="pl-k">=</span> <span class="pl-c1">true</span>;</td>
      </tr>
      <tr>
        <td id="L217" class="blob-num js-line-number" data-line-number="217"></td>
        <td id="LC217" class="blob-code blob-code-inner js-file-line">      <span class="pl-k">return</span>;</td>
      </tr>
      <tr>
        <td id="L218" class="blob-num js-line-number" data-line-number="218"></td>
        <td id="LC218" class="blob-code blob-code-inner js-file-line">    }</td>
      </tr>
      <tr>
        <td id="L219" class="blob-num js-line-number" data-line-number="219"></td>
        <td id="LC219" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L220" class="blob-num js-line-number" data-line-number="220"></td>
        <td id="LC220" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Set singular and plural references for the word.</span></td>
      </tr>
      <tr>
        <td id="L221" class="blob-num js-line-number" data-line-number="221"></td>
        <td id="LC221" class="blob-code blob-code-inner js-file-line">    <span class="pl-smi">pluralize</span>.<span class="pl-en">addPluralRule</span>(word, <span class="pl-s"><span class="pl-pds">&#39;</span>$0<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L222" class="blob-num js-line-number" data-line-number="222"></td>
        <td id="LC222" class="blob-code blob-code-inner js-file-line">    <span class="pl-smi">pluralize</span>.<span class="pl-en">addSingularRule</span>(word, <span class="pl-s"><span class="pl-pds">&#39;</span>$0<span class="pl-pds">&#39;</span></span>);</td>
      </tr>
      <tr>
        <td id="L223" class="blob-num js-line-number" data-line-number="223"></td>
        <td id="LC223" class="blob-code blob-code-inner js-file-line">  };</td>
      </tr>
      <tr>
        <td id="L224" class="blob-num js-line-number" data-line-number="224"></td>
        <td id="LC224" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L225" class="blob-num js-line-number" data-line-number="225"></td>
        <td id="LC225" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L226" class="blob-num js-line-number" data-line-number="226"></td>
        <td id="LC226" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Add an irregular word definition.</span></td>
      </tr>
      <tr>
        <td id="L227" class="blob-num js-line-number" data-line-number="227"></td>
        <td id="LC227" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   *</span></td>
      </tr>
      <tr>
        <td id="L228" class="blob-num js-line-number" data-line-number="228"></td>
        <td id="LC228" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{string}</span> <span class="pl-smi">single</span></span></td>
      </tr>
      <tr>
        <td id="L229" class="blob-num js-line-number" data-line-number="229"></td>
        <td id="LC229" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * <span class="pl-k">@param</span> <span class="pl-en">{string}</span> <span class="pl-smi">plural</span></span></td>
      </tr>
      <tr>
        <td id="L230" class="blob-num js-line-number" data-line-number="230"></td>
        <td id="LC230" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L231" class="blob-num js-line-number" data-line-number="231"></td>
        <td id="LC231" class="blob-code blob-code-inner js-file-line">  <span class="pl-smi">pluralize</span>.<span class="pl-en">addIrregularRule</span> <span class="pl-k">=</span> <span class="pl-k">function</span> (<span class="pl-smi">single</span>, <span class="pl-smi">plural</span>) {</td>
      </tr>
      <tr>
        <td id="L232" class="blob-num js-line-number" data-line-number="232"></td>
        <td id="LC232" class="blob-code blob-code-inner js-file-line">    plural <span class="pl-k">=</span> <span class="pl-smi">plural</span>.<span class="pl-c1">toLowerCase</span>();</td>
      </tr>
      <tr>
        <td id="L233" class="blob-num js-line-number" data-line-number="233"></td>
        <td id="LC233" class="blob-code blob-code-inner js-file-line">    single <span class="pl-k">=</span> <span class="pl-smi">single</span>.<span class="pl-c1">toLowerCase</span>();</td>
      </tr>
      <tr>
        <td id="L234" class="blob-num js-line-number" data-line-number="234"></td>
        <td id="LC234" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L235" class="blob-num js-line-number" data-line-number="235"></td>
        <td id="LC235" class="blob-code blob-code-inner js-file-line">    irregularSingles[single] <span class="pl-k">=</span> plural;</td>
      </tr>
      <tr>
        <td id="L236" class="blob-num js-line-number" data-line-number="236"></td>
        <td id="LC236" class="blob-code blob-code-inner js-file-line">    irregularPlurals[plural] <span class="pl-k">=</span> single;</td>
      </tr>
      <tr>
        <td id="L237" class="blob-num js-line-number" data-line-number="237"></td>
        <td id="LC237" class="blob-code blob-code-inner js-file-line">  };</td>
      </tr>
      <tr>
        <td id="L238" class="blob-num js-line-number" data-line-number="238"></td>
        <td id="LC238" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L239" class="blob-num js-line-number" data-line-number="239"></td>
        <td id="LC239" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L240" class="blob-num js-line-number" data-line-number="240"></td>
        <td id="LC240" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Irregular rules.</span></td>
      </tr>
      <tr>
        <td id="L241" class="blob-num js-line-number" data-line-number="241"></td>
        <td id="LC241" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L242" class="blob-num js-line-number" data-line-number="242"></td>
        <td id="LC242" class="blob-code blob-code-inner js-file-line">  [</td>
      </tr>
      <tr>
        <td id="L243" class="blob-num js-line-number" data-line-number="243"></td>
        <td id="LC243" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Pronouns.</span></td>
      </tr>
      <tr>
        <td id="L244" class="blob-num js-line-number" data-line-number="244"></td>
        <td id="LC244" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>I<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>we<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L245" class="blob-num js-line-number" data-line-number="245"></td>
        <td id="LC245" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>me<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>us<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L246" class="blob-num js-line-number" data-line-number="246"></td>
        <td id="LC246" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>he<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>they<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L247" class="blob-num js-line-number" data-line-number="247"></td>
        <td id="LC247" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>she<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>they<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L248" class="blob-num js-line-number" data-line-number="248"></td>
        <td id="LC248" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>them<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>them<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L249" class="blob-num js-line-number" data-line-number="249"></td>
        <td id="LC249" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>myself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>ourselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L250" class="blob-num js-line-number" data-line-number="250"></td>
        <td id="LC250" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>yourself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>yourselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L251" class="blob-num js-line-number" data-line-number="251"></td>
        <td id="LC251" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>itself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>themselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L252" class="blob-num js-line-number" data-line-number="252"></td>
        <td id="LC252" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>herself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>themselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L253" class="blob-num js-line-number" data-line-number="253"></td>
        <td id="LC253" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>himself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>themselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L254" class="blob-num js-line-number" data-line-number="254"></td>
        <td id="LC254" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>themself<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>themselves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L255" class="blob-num js-line-number" data-line-number="255"></td>
        <td id="LC255" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>is<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>are<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L256" class="blob-num js-line-number" data-line-number="256"></td>
        <td id="LC256" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>was<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>were<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L257" class="blob-num js-line-number" data-line-number="257"></td>
        <td id="LC257" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>has<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>have<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L258" class="blob-num js-line-number" data-line-number="258"></td>
        <td id="LC258" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>this<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>these<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L259" class="blob-num js-line-number" data-line-number="259"></td>
        <td id="LC259" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>that<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>those<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L260" class="blob-num js-line-number" data-line-number="260"></td>
        <td id="LC260" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Words ending in with a consonant and `o`.</span></td>
      </tr>
      <tr>
        <td id="L261" class="blob-num js-line-number" data-line-number="261"></td>
        <td id="LC261" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>echo<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>echoes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L262" class="blob-num js-line-number" data-line-number="262"></td>
        <td id="LC262" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>dingo<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>dingoes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L263" class="blob-num js-line-number" data-line-number="263"></td>
        <td id="LC263" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>volcano<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>volcanoes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L264" class="blob-num js-line-number" data-line-number="264"></td>
        <td id="LC264" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>tornado<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>tornadoes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L265" class="blob-num js-line-number" data-line-number="265"></td>
        <td id="LC265" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>torpedo<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>torpedoes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L266" class="blob-num js-line-number" data-line-number="266"></td>
        <td id="LC266" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Ends with `us`.</span></td>
      </tr>
      <tr>
        <td id="L267" class="blob-num js-line-number" data-line-number="267"></td>
        <td id="LC267" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>genus<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>genera<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L268" class="blob-num js-line-number" data-line-number="268"></td>
        <td id="LC268" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>viscus<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>viscera<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L269" class="blob-num js-line-number" data-line-number="269"></td>
        <td id="LC269" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Ends with `ma`.</span></td>
      </tr>
      <tr>
        <td id="L270" class="blob-num js-line-number" data-line-number="270"></td>
        <td id="LC270" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>stigma<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>stigmata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L271" class="blob-num js-line-number" data-line-number="271"></td>
        <td id="LC271" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>stoma<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>stomata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L272" class="blob-num js-line-number" data-line-number="272"></td>
        <td id="LC272" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>dogma<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>dogmata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L273" class="blob-num js-line-number" data-line-number="273"></td>
        <td id="LC273" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>lemma<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>lemmata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L274" class="blob-num js-line-number" data-line-number="274"></td>
        <td id="LC274" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>schema<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>schemata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L275" class="blob-num js-line-number" data-line-number="275"></td>
        <td id="LC275" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>anathema<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>anathemata<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L276" class="blob-num js-line-number" data-line-number="276"></td>
        <td id="LC276" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Other irregular rules.</span></td>
      </tr>
      <tr>
        <td id="L277" class="blob-num js-line-number" data-line-number="277"></td>
        <td id="LC277" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>ox<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>oxen<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L278" class="blob-num js-line-number" data-line-number="278"></td>
        <td id="LC278" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>axe<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>axes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L279" class="blob-num js-line-number" data-line-number="279"></td>
        <td id="LC279" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>die<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>dice<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L280" class="blob-num js-line-number" data-line-number="280"></td>
        <td id="LC280" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>yes<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>yeses<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L281" class="blob-num js-line-number" data-line-number="281"></td>
        <td id="LC281" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>foot<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>feet<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L282" class="blob-num js-line-number" data-line-number="282"></td>
        <td id="LC282" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>eave<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>eaves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L283" class="blob-num js-line-number" data-line-number="283"></td>
        <td id="LC283" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>goose<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>geese<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L284" class="blob-num js-line-number" data-line-number="284"></td>
        <td id="LC284" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>tooth<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>teeth<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L285" class="blob-num js-line-number" data-line-number="285"></td>
        <td id="LC285" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>quiz<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>quizzes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L286" class="blob-num js-line-number" data-line-number="286"></td>
        <td id="LC286" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>human<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>humans<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L287" class="blob-num js-line-number" data-line-number="287"></td>
        <td id="LC287" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>proof<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>proofs<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L288" class="blob-num js-line-number" data-line-number="288"></td>
        <td id="LC288" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>carve<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>carves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L289" class="blob-num js-line-number" data-line-number="289"></td>
        <td id="LC289" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>valve<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>valves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L290" class="blob-num js-line-number" data-line-number="290"></td>
        <td id="LC290" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>looey<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>looies<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L291" class="blob-num js-line-number" data-line-number="291"></td>
        <td id="LC291" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>thief<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>thieves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L292" class="blob-num js-line-number" data-line-number="292"></td>
        <td id="LC292" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>groove<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>grooves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L293" class="blob-num js-line-number" data-line-number="293"></td>
        <td id="LC293" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>pickaxe<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>pickaxes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L294" class="blob-num js-line-number" data-line-number="294"></td>
        <td id="LC294" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>whiskey<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>whiskies<span class="pl-pds">&#39;</span></span>]</td>
      </tr>
      <tr>
        <td id="L295" class="blob-num js-line-number" data-line-number="295"></td>
        <td id="LC295" class="blob-code blob-code-inner js-file-line">  ].<span class="pl-c1">forEach</span>(<span class="pl-k">function</span> (<span class="pl-smi">rule</span>) {</td>
      </tr>
      <tr>
        <td id="L296" class="blob-num js-line-number" data-line-number="296"></td>
        <td id="LC296" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">pluralize</span>.<span class="pl-en">addIrregularRule</span>(rule[<span class="pl-c1">0</span>], rule[<span class="pl-c1">1</span>]);</td>
      </tr>
      <tr>
        <td id="L297" class="blob-num js-line-number" data-line-number="297"></td>
        <td id="LC297" class="blob-code blob-code-inner js-file-line">  });</td>
      </tr>
      <tr>
        <td id="L298" class="blob-num js-line-number" data-line-number="298"></td>
        <td id="LC298" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L299" class="blob-num js-line-number" data-line-number="299"></td>
        <td id="LC299" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L300" class="blob-num js-line-number" data-line-number="300"></td>
        <td id="LC300" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Pluralization rules.</span></td>
      </tr>
      <tr>
        <td id="L301" class="blob-num js-line-number" data-line-number="301"></td>
        <td id="LC301" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L302" class="blob-num js-line-number" data-line-number="302"></td>
        <td id="LC302" class="blob-code blob-code-inner js-file-line">  [</td>
      </tr>
      <tr>
        <td id="L303" class="blob-num js-line-number" data-line-number="303"></td>
        <td id="LC303" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>s<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>s<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L304" class="blob-num js-line-number" data-line-number="304"></td>
        <td id="LC304" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(<span class="pl-c1">[<span class="pl-k">^</span>aeiou]</span>ese)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L305" class="blob-num js-line-number" data-line-number="305"></td>
        <td id="LC305" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(ax<span class="pl-k">|</span>test)is<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1es<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L306" class="blob-num js-line-number" data-line-number="306"></td>
        <td id="LC306" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(alias<span class="pl-k">|</span><span class="pl-c1">[<span class="pl-k">^</span>aou]</span>us<span class="pl-k">|</span>tlas<span class="pl-k">|</span>gas<span class="pl-k">|</span>ris)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1es<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L307" class="blob-num js-line-number" data-line-number="307"></td>
        <td id="LC307" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(e<span class="pl-c1">[mn]</span>u)s<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1s<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L308" class="blob-num js-line-number" data-line-number="308"></td>
        <td id="LC308" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(<span class="pl-c1">[<span class="pl-k">^</span>l]</span>ias<span class="pl-k">|</span><span class="pl-c1">[aeiou]</span>las<span class="pl-k">|</span><span class="pl-c1">[emjzr]</span>as<span class="pl-k">|</span><span class="pl-c1">[iu]</span>am)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L309" class="blob-num js-line-number" data-line-number="309"></td>
        <td id="LC309" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(alumn<span class="pl-k">|</span>syllab<span class="pl-k">|</span>octop<span class="pl-k">|</span>vir<span class="pl-k">|</span>radi<span class="pl-k">|</span>nucle<span class="pl-k">|</span>fung<span class="pl-k">|</span>cact<span class="pl-k">|</span>stimul<span class="pl-k">|</span>termin<span class="pl-k">|</span>bacill<span class="pl-k">|</span>foc<span class="pl-k">|</span>uter<span class="pl-k">|</span>loc<span class="pl-k">|</span>strat)(?:us<span class="pl-k">|</span>i)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1i<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L310" class="blob-num js-line-number" data-line-number="310"></td>
        <td id="LC310" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(alumn<span class="pl-k">|</span>alg<span class="pl-k">|</span>vertebr)(?:a<span class="pl-k">|</span>ae)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ae<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L311" class="blob-num js-line-number" data-line-number="311"></td>
        <td id="LC311" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(seraph<span class="pl-k">|</span>cherub)(?:im)<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1im<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L312" class="blob-num js-line-number" data-line-number="312"></td>
        <td id="LC312" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(her<span class="pl-k">|</span>at<span class="pl-k">|</span>gr)o<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1oes<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L313" class="blob-num js-line-number" data-line-number="313"></td>
        <td id="LC313" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(agend<span class="pl-k">|</span>addend<span class="pl-k">|</span>millenni<span class="pl-k">|</span>dat<span class="pl-k">|</span>extrem<span class="pl-k">|</span>bacteri<span class="pl-k">|</span>desiderat<span class="pl-k">|</span>strat<span class="pl-k">|</span>candelabr<span class="pl-k">|</span>errat<span class="pl-k">|</span>ov<span class="pl-k">|</span>symposi<span class="pl-k">|</span>curricul<span class="pl-k">|</span>automat<span class="pl-k">|</span>quor)(?:a<span class="pl-k">|</span>um)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1a<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L314" class="blob-num js-line-number" data-line-number="314"></td>
        <td id="LC314" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(apheli<span class="pl-k">|</span>hyperbat<span class="pl-k">|</span>periheli<span class="pl-k">|</span>asyndet<span class="pl-k">|</span>noumen<span class="pl-k">|</span>phenomen<span class="pl-k">|</span>criteri<span class="pl-k">|</span>organ<span class="pl-k">|</span>prolegomen<span class="pl-k">|</span>hedr<span class="pl-k">|</span>automat)(?:a<span class="pl-k">|</span>on)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1a<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L315" class="blob-num js-line-number" data-line-number="315"></td>
        <td id="LC315" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>sis<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>ses<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L316" class="blob-num js-line-number" data-line-number="316"></td>
        <td id="LC316" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(?:(kni<span class="pl-k">|</span>wi<span class="pl-k">|</span>li)fe<span class="pl-k">|</span>(ar<span class="pl-k">|</span>l<span class="pl-k">|</span>ea<span class="pl-k">|</span>eo<span class="pl-k">|</span>oa<span class="pl-k">|</span>hoo)f)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1$2ves<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L317" class="blob-num js-line-number" data-line-number="317"></td>
        <td id="LC317" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(<span class="pl-c1">[<span class="pl-k">^</span>aeiouy]</span><span class="pl-k">|</span>qu)y<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ies<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L318" class="blob-num js-line-number" data-line-number="318"></td>
        <td id="LC318" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(<span class="pl-c1">[<span class="pl-k">^</span>ch][ieo][ln]</span>)ey<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ies<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L319" class="blob-num js-line-number" data-line-number="319"></td>
        <td id="LC319" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(x<span class="pl-k">|</span>ch<span class="pl-k">|</span>ss<span class="pl-k">|</span>sh<span class="pl-k">|</span>zz)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1es<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L320" class="blob-num js-line-number" data-line-number="320"></td>
        <td id="LC320" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(matr<span class="pl-k">|</span>cod<span class="pl-k">|</span>mur<span class="pl-k">|</span>sil<span class="pl-k">|</span>vert<span class="pl-k">|</span>ind<span class="pl-k">|</span>append)(?:ix<span class="pl-k">|</span>ex)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ices<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L321" class="blob-num js-line-number" data-line-number="321"></td>
        <td id="LC321" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(m<span class="pl-k">|</span>l)(?:ice<span class="pl-k">|</span>ouse)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ice<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L322" class="blob-num js-line-number" data-line-number="322"></td>
        <td id="LC322" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(pe)(?:rson<span class="pl-k">|</span>ople)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ople<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L323" class="blob-num js-line-number" data-line-number="323"></td>
        <td id="LC323" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(child)(?:ren)<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ren<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L324" class="blob-num js-line-number" data-line-number="324"></td>
        <td id="LC324" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>eaux<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$0<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L325" class="blob-num js-line-number" data-line-number="325"></td>
        <td id="LC325" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>m<span class="pl-c1">[ae]</span>n<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>men<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L326" class="blob-num js-line-number" data-line-number="326"></td>
        <td id="LC326" class="blob-code blob-code-inner js-file-line">    [<span class="pl-s"><span class="pl-pds">&#39;</span>thou<span class="pl-pds">&#39;</span></span>, <span class="pl-s"><span class="pl-pds">&#39;</span>you<span class="pl-pds">&#39;</span></span>]</td>
      </tr>
      <tr>
        <td id="L327" class="blob-num js-line-number" data-line-number="327"></td>
        <td id="LC327" class="blob-code blob-code-inner js-file-line">  ].<span class="pl-c1">forEach</span>(<span class="pl-k">function</span> (<span class="pl-smi">rule</span>) {</td>
      </tr>
      <tr>
        <td id="L328" class="blob-num js-line-number" data-line-number="328"></td>
        <td id="LC328" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">pluralize</span>.<span class="pl-en">addPluralRule</span>(rule[<span class="pl-c1">0</span>], rule[<span class="pl-c1">1</span>]);</td>
      </tr>
      <tr>
        <td id="L329" class="blob-num js-line-number" data-line-number="329"></td>
        <td id="LC329" class="blob-code blob-code-inner js-file-line">  });</td>
      </tr>
      <tr>
        <td id="L330" class="blob-num js-line-number" data-line-number="330"></td>
        <td id="LC330" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L331" class="blob-num js-line-number" data-line-number="331"></td>
        <td id="LC331" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L332" class="blob-num js-line-number" data-line-number="332"></td>
        <td id="LC332" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Singularization rules.</span></td>
      </tr>
      <tr>
        <td id="L333" class="blob-num js-line-number" data-line-number="333"></td>
        <td id="LC333" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L334" class="blob-num js-line-number" data-line-number="334"></td>
        <td id="LC334" class="blob-code blob-code-inner js-file-line">  [</td>
      </tr>
      <tr>
        <td id="L335" class="blob-num js-line-number" data-line-number="335"></td>
        <td id="LC335" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>s<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span><span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L336" class="blob-num js-line-number" data-line-number="336"></td>
        <td id="LC336" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(ss)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L337" class="blob-num js-line-number" data-line-number="337"></td>
        <td id="LC337" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>((a)naly<span class="pl-k">|</span>(b)a<span class="pl-k">|</span>(d)iagno<span class="pl-k">|</span>(p)arenthe<span class="pl-k">|</span>(p)rogno<span class="pl-k">|</span>(s)ynop<span class="pl-k">|</span>(t)he)(?:sis<span class="pl-k">|</span>ses)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1sis<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L338" class="blob-num js-line-number" data-line-number="338"></td>
        <td id="LC338" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(<span class="pl-k">^</span>analy)(?:sis<span class="pl-k">|</span>ses)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1sis<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L339" class="blob-num js-line-number" data-line-number="339"></td>
        <td id="LC339" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(wi<span class="pl-k">|</span>kni<span class="pl-k">|</span>(?:after<span class="pl-k">|</span>half<span class="pl-k">|</span>high<span class="pl-k">|</span>low<span class="pl-k">|</span>mid<span class="pl-k">|</span>non<span class="pl-k">|</span>night<span class="pl-k">|</span><span class="pl-c1">[<span class="pl-k">^</span><span class="pl-c1">\w</span>]</span><span class="pl-k">|</span><span class="pl-k">^</span>)li)ves<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1fe<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L340" class="blob-num js-line-number" data-line-number="340"></td>
        <td id="LC340" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(ar<span class="pl-k">|</span>(?:wo<span class="pl-k">|</span><span class="pl-c1">[ae]</span>)l<span class="pl-k">|</span><span class="pl-c1">[eo][ao]</span>)ves<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1f<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L341" class="blob-num js-line-number" data-line-number="341"></td>
        <td id="LC341" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>ies<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>y<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L342" class="blob-num js-line-number" data-line-number="342"></td>
        <td id="LC342" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span><span class="pl-k">\b</span>(<span class="pl-c1">[pl]</span><span class="pl-k">|</span>zomb<span class="pl-k">|</span>(?:neck<span class="pl-k">|</span>cross)<span class="pl-k">?</span>t<span class="pl-k">|</span>coll<span class="pl-k">|</span>faer<span class="pl-k">|</span>food<span class="pl-k">|</span>gen<span class="pl-k">|</span>goon<span class="pl-k">|</span>group<span class="pl-k">|</span>lass<span class="pl-k">|</span>talk<span class="pl-k">|</span>goal<span class="pl-k">|</span>cut)ies<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ie<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L343" class="blob-num js-line-number" data-line-number="343"></td>
        <td id="LC343" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span><span class="pl-k">\b</span>(mon<span class="pl-k">|</span>smil)ies<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ey<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L344" class="blob-num js-line-number" data-line-number="344"></td>
        <td id="LC344" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(m<span class="pl-k">|</span>l)ice<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ouse<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L345" class="blob-num js-line-number" data-line-number="345"></td>
        <td id="LC345" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(seraph<span class="pl-k">|</span>cherub)im<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L346" class="blob-num js-line-number" data-line-number="346"></td>
        <td id="LC346" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(x<span class="pl-k">|</span>ch<span class="pl-k">|</span>ss<span class="pl-k">|</span>sh<span class="pl-k">|</span>zz<span class="pl-k">|</span>tto<span class="pl-k">|</span>go<span class="pl-k">|</span>cho<span class="pl-k">|</span>alias<span class="pl-k">|</span><span class="pl-c1">[<span class="pl-k">^</span>aou]</span>us<span class="pl-k">|</span>tlas<span class="pl-k">|</span>gas<span class="pl-k">|</span>(?:her<span class="pl-k">|</span>at<span class="pl-k">|</span>gr)o<span class="pl-k">|</span>ris)(?:es)<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L347" class="blob-num js-line-number" data-line-number="347"></td>
        <td id="LC347" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(e<span class="pl-c1">[mn]</span>u)s<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L348" class="blob-num js-line-number" data-line-number="348"></td>
        <td id="LC348" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(movie<span class="pl-k">|</span>twelve)s<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L349" class="blob-num js-line-number" data-line-number="349"></td>
        <td id="LC349" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(cris<span class="pl-k">|</span>test<span class="pl-k">|</span>diagnos)(?:is<span class="pl-k">|</span>es)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1is<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L350" class="blob-num js-line-number" data-line-number="350"></td>
        <td id="LC350" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(alumn<span class="pl-k">|</span>syllab<span class="pl-k">|</span>octop<span class="pl-k">|</span>vir<span class="pl-k">|</span>radi<span class="pl-k">|</span>nucle<span class="pl-k">|</span>fung<span class="pl-k">|</span>cact<span class="pl-k">|</span>stimul<span class="pl-k">|</span>termin<span class="pl-k">|</span>bacill<span class="pl-k">|</span>foc<span class="pl-k">|</span>uter<span class="pl-k">|</span>loc<span class="pl-k">|</span>strat)(?:us<span class="pl-k">|</span>i)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1us<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L351" class="blob-num js-line-number" data-line-number="351"></td>
        <td id="LC351" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(agend<span class="pl-k">|</span>addend<span class="pl-k">|</span>millenni<span class="pl-k">|</span>dat<span class="pl-k">|</span>extrem<span class="pl-k">|</span>bacteri<span class="pl-k">|</span>desiderat<span class="pl-k">|</span>strat<span class="pl-k">|</span>candelabr<span class="pl-k">|</span>errat<span class="pl-k">|</span>ov<span class="pl-k">|</span>symposi<span class="pl-k">|</span>curricul<span class="pl-k">|</span>quor)a<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1um<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L352" class="blob-num js-line-number" data-line-number="352"></td>
        <td id="LC352" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(apheli<span class="pl-k">|</span>hyperbat<span class="pl-k">|</span>periheli<span class="pl-k">|</span>asyndet<span class="pl-k">|</span>noumen<span class="pl-k">|</span>phenomen<span class="pl-k">|</span>criteri<span class="pl-k">|</span>organ<span class="pl-k">|</span>prolegomen<span class="pl-k">|</span>hedr<span class="pl-k">|</span>automat)a<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1on<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L353" class="blob-num js-line-number" data-line-number="353"></td>
        <td id="LC353" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(alumn<span class="pl-k">|</span>alg<span class="pl-k">|</span>vertebr)ae<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1a<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L354" class="blob-num js-line-number" data-line-number="354"></td>
        <td id="LC354" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(cod<span class="pl-k">|</span>mur<span class="pl-k">|</span>sil<span class="pl-k">|</span>vert<span class="pl-k">|</span>ind)ices<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ex<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L355" class="blob-num js-line-number" data-line-number="355"></td>
        <td id="LC355" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(matr<span class="pl-k">|</span>append)ices<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1ix<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L356" class="blob-num js-line-number" data-line-number="356"></td>
        <td id="LC356" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(pe)(rson<span class="pl-k">|</span>ople)<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1rson<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L357" class="blob-num js-line-number" data-line-number="357"></td>
        <td id="LC357" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(child)ren<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L358" class="blob-num js-line-number" data-line-number="358"></td>
        <td id="LC358" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>(eau)x<span class="pl-k">?</span><span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>$1<span class="pl-pds">&#39;</span></span>],</td>
      </tr>
      <tr>
        <td id="L359" class="blob-num js-line-number" data-line-number="359"></td>
        <td id="LC359" class="blob-code blob-code-inner js-file-line">    [<span class="pl-sr"><span class="pl-pds">/</span>men<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-s"><span class="pl-pds">&#39;</span>man<span class="pl-pds">&#39;</span></span>]</td>
      </tr>
      <tr>
        <td id="L360" class="blob-num js-line-number" data-line-number="360"></td>
        <td id="LC360" class="blob-code blob-code-inner js-file-line">  ].<span class="pl-c1">forEach</span>(<span class="pl-k">function</span> (<span class="pl-smi">rule</span>) {</td>
      </tr>
      <tr>
        <td id="L361" class="blob-num js-line-number" data-line-number="361"></td>
        <td id="LC361" class="blob-code blob-code-inner js-file-line">    <span class="pl-k">return</span> <span class="pl-smi">pluralize</span>.<span class="pl-en">addSingularRule</span>(rule[<span class="pl-c1">0</span>], rule[<span class="pl-c1">1</span>]);</td>
      </tr>
      <tr>
        <td id="L362" class="blob-num js-line-number" data-line-number="362"></td>
        <td id="LC362" class="blob-code blob-code-inner js-file-line">  });</td>
      </tr>
      <tr>
        <td id="L363" class="blob-num js-line-number" data-line-number="363"></td>
        <td id="LC363" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L364" class="blob-num js-line-number" data-line-number="364"></td>
        <td id="LC364" class="blob-code blob-code-inner js-file-line">  <span class="pl-c"><span class="pl-c">/**</span></span></td>
      </tr>
      <tr>
        <td id="L365" class="blob-num js-line-number" data-line-number="365"></td>
        <td id="LC365" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   * Uncountable rules.</span></td>
      </tr>
      <tr>
        <td id="L366" class="blob-num js-line-number" data-line-number="366"></td>
        <td id="LC366" class="blob-code blob-code-inner js-file-line"><span class="pl-c">   <span class="pl-c">*/</span></span></td>
      </tr>
      <tr>
        <td id="L367" class="blob-num js-line-number" data-line-number="367"></td>
        <td id="LC367" class="blob-code blob-code-inner js-file-line">  [</td>
      </tr>
      <tr>
        <td id="L368" class="blob-num js-line-number" data-line-number="368"></td>
        <td id="LC368" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Singular words with no plurals.</span></td>
      </tr>
      <tr>
        <td id="L369" class="blob-num js-line-number" data-line-number="369"></td>
        <td id="LC369" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>advice<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L370" class="blob-num js-line-number" data-line-number="370"></td>
        <td id="LC370" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>adulthood<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L371" class="blob-num js-line-number" data-line-number="371"></td>
        <td id="LC371" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>agenda<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L372" class="blob-num js-line-number" data-line-number="372"></td>
        <td id="LC372" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>aid<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L373" class="blob-num js-line-number" data-line-number="373"></td>
        <td id="LC373" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>alcohol<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L374" class="blob-num js-line-number" data-line-number="374"></td>
        <td id="LC374" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>ammo<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L375" class="blob-num js-line-number" data-line-number="375"></td>
        <td id="LC375" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>athletics<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L376" class="blob-num js-line-number" data-line-number="376"></td>
        <td id="LC376" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>bison<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L377" class="blob-num js-line-number" data-line-number="377"></td>
        <td id="LC377" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>blood<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L378" class="blob-num js-line-number" data-line-number="378"></td>
        <td id="LC378" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>bream<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L379" class="blob-num js-line-number" data-line-number="379"></td>
        <td id="LC379" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>buffalo<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L380" class="blob-num js-line-number" data-line-number="380"></td>
        <td id="LC380" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>butter<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L381" class="blob-num js-line-number" data-line-number="381"></td>
        <td id="LC381" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>carp<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L382" class="blob-num js-line-number" data-line-number="382"></td>
        <td id="LC382" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>cash<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L383" class="blob-num js-line-number" data-line-number="383"></td>
        <td id="LC383" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>chassis<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L384" class="blob-num js-line-number" data-line-number="384"></td>
        <td id="LC384" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>chess<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L385" class="blob-num js-line-number" data-line-number="385"></td>
        <td id="LC385" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>clothing<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L386" class="blob-num js-line-number" data-line-number="386"></td>
        <td id="LC386" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>commerce<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L387" class="blob-num js-line-number" data-line-number="387"></td>
        <td id="LC387" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>cod<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L388" class="blob-num js-line-number" data-line-number="388"></td>
        <td id="LC388" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>cooperation<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L389" class="blob-num js-line-number" data-line-number="389"></td>
        <td id="LC389" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>corps<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L390" class="blob-num js-line-number" data-line-number="390"></td>
        <td id="LC390" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>digestion<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L391" class="blob-num js-line-number" data-line-number="391"></td>
        <td id="LC391" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>debris<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L392" class="blob-num js-line-number" data-line-number="392"></td>
        <td id="LC392" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>diabetes<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L393" class="blob-num js-line-number" data-line-number="393"></td>
        <td id="LC393" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>energy<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L394" class="blob-num js-line-number" data-line-number="394"></td>
        <td id="LC394" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>equipment<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L395" class="blob-num js-line-number" data-line-number="395"></td>
        <td id="LC395" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>elk<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L396" class="blob-num js-line-number" data-line-number="396"></td>
        <td id="LC396" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>excretion<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L397" class="blob-num js-line-number" data-line-number="397"></td>
        <td id="LC397" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>expertise<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L398" class="blob-num js-line-number" data-line-number="398"></td>
        <td id="LC398" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>flounder<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L399" class="blob-num js-line-number" data-line-number="399"></td>
        <td id="LC399" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>fun<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L400" class="blob-num js-line-number" data-line-number="400"></td>
        <td id="LC400" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>gallows<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L401" class="blob-num js-line-number" data-line-number="401"></td>
        <td id="LC401" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>garbage<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L402" class="blob-num js-line-number" data-line-number="402"></td>
        <td id="LC402" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>graffiti<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L403" class="blob-num js-line-number" data-line-number="403"></td>
        <td id="LC403" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>headquarters<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L404" class="blob-num js-line-number" data-line-number="404"></td>
        <td id="LC404" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>health<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L405" class="blob-num js-line-number" data-line-number="405"></td>
        <td id="LC405" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>herpes<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L406" class="blob-num js-line-number" data-line-number="406"></td>
        <td id="LC406" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>highjinks<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L407" class="blob-num js-line-number" data-line-number="407"></td>
        <td id="LC407" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>homework<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L408" class="blob-num js-line-number" data-line-number="408"></td>
        <td id="LC408" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>housework<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L409" class="blob-num js-line-number" data-line-number="409"></td>
        <td id="LC409" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>information<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L410" class="blob-num js-line-number" data-line-number="410"></td>
        <td id="LC410" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>jeans<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L411" class="blob-num js-line-number" data-line-number="411"></td>
        <td id="LC411" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>justice<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L412" class="blob-num js-line-number" data-line-number="412"></td>
        <td id="LC412" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>kudos<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L413" class="blob-num js-line-number" data-line-number="413"></td>
        <td id="LC413" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>labour<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L414" class="blob-num js-line-number" data-line-number="414"></td>
        <td id="LC414" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>literature<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L415" class="blob-num js-line-number" data-line-number="415"></td>
        <td id="LC415" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>machinery<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L416" class="blob-num js-line-number" data-line-number="416"></td>
        <td id="LC416" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>mackerel<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L417" class="blob-num js-line-number" data-line-number="417"></td>
        <td id="LC417" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>mail<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L418" class="blob-num js-line-number" data-line-number="418"></td>
        <td id="LC418" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>media<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L419" class="blob-num js-line-number" data-line-number="419"></td>
        <td id="LC419" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>mews<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L420" class="blob-num js-line-number" data-line-number="420"></td>
        <td id="LC420" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>moose<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L421" class="blob-num js-line-number" data-line-number="421"></td>
        <td id="LC421" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>music<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L422" class="blob-num js-line-number" data-line-number="422"></td>
        <td id="LC422" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>news<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L423" class="blob-num js-line-number" data-line-number="423"></td>
        <td id="LC423" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>pike<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L424" class="blob-num js-line-number" data-line-number="424"></td>
        <td id="LC424" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>plankton<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L425" class="blob-num js-line-number" data-line-number="425"></td>
        <td id="LC425" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>pliers<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L426" class="blob-num js-line-number" data-line-number="426"></td>
        <td id="LC426" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>pollution<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L427" class="blob-num js-line-number" data-line-number="427"></td>
        <td id="LC427" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>premises<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L428" class="blob-num js-line-number" data-line-number="428"></td>
        <td id="LC428" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>rain<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L429" class="blob-num js-line-number" data-line-number="429"></td>
        <td id="LC429" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>research<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L430" class="blob-num js-line-number" data-line-number="430"></td>
        <td id="LC430" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>rice<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L431" class="blob-num js-line-number" data-line-number="431"></td>
        <td id="LC431" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>salmon<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L432" class="blob-num js-line-number" data-line-number="432"></td>
        <td id="LC432" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>scissors<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L433" class="blob-num js-line-number" data-line-number="433"></td>
        <td id="LC433" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>series<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L434" class="blob-num js-line-number" data-line-number="434"></td>
        <td id="LC434" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>sewage<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L435" class="blob-num js-line-number" data-line-number="435"></td>
        <td id="LC435" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>shambles<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L436" class="blob-num js-line-number" data-line-number="436"></td>
        <td id="LC436" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>shrimp<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L437" class="blob-num js-line-number" data-line-number="437"></td>
        <td id="LC437" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>species<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L438" class="blob-num js-line-number" data-line-number="438"></td>
        <td id="LC438" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>staff<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L439" class="blob-num js-line-number" data-line-number="439"></td>
        <td id="LC439" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>swine<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L440" class="blob-num js-line-number" data-line-number="440"></td>
        <td id="LC440" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>trout<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L441" class="blob-num js-line-number" data-line-number="441"></td>
        <td id="LC441" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>traffic<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L442" class="blob-num js-line-number" data-line-number="442"></td>
        <td id="LC442" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>transporation<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L443" class="blob-num js-line-number" data-line-number="443"></td>
        <td id="LC443" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>tuna<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L444" class="blob-num js-line-number" data-line-number="444"></td>
        <td id="LC444" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>wealth<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L445" class="blob-num js-line-number" data-line-number="445"></td>
        <td id="LC445" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>welfare<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L446" class="blob-num js-line-number" data-line-number="446"></td>
        <td id="LC446" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>whiting<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L447" class="blob-num js-line-number" data-line-number="447"></td>
        <td id="LC447" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>wildebeest<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L448" class="blob-num js-line-number" data-line-number="448"></td>
        <td id="LC448" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>wildlife<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L449" class="blob-num js-line-number" data-line-number="449"></td>
        <td id="LC449" class="blob-code blob-code-inner js-file-line">    <span class="pl-s"><span class="pl-pds">&#39;</span>you<span class="pl-pds">&#39;</span></span>,</td>
      </tr>
      <tr>
        <td id="L450" class="blob-num js-line-number" data-line-number="450"></td>
        <td id="LC450" class="blob-code blob-code-inner js-file-line">    <span class="pl-c"><span class="pl-c">//</span> Regexes.</span></td>
      </tr>
      <tr>
        <td id="L451" class="blob-num js-line-number" data-line-number="451"></td>
        <td id="LC451" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>pox<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-c"><span class="pl-c">//</span> &quot;chickpox&quot;, &quot;smallpox&quot;</span></td>
      </tr>
      <tr>
        <td id="L452" class="blob-num js-line-number" data-line-number="452"></td>
        <td id="LC452" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>ois<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>,</td>
      </tr>
      <tr>
        <td id="L453" class="blob-num js-line-number" data-line-number="453"></td>
        <td id="LC453" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>deer<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-c"><span class="pl-c">//</span> &quot;deer&quot;, &quot;reindeer&quot;</span></td>
      </tr>
      <tr>
        <td id="L454" class="blob-num js-line-number" data-line-number="454"></td>
        <td id="LC454" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>fish<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>, <span class="pl-c"><span class="pl-c">//</span> &quot;fish&quot;, &quot;blowfish&quot;, &quot;angelfish&quot;</span></td>
      </tr>
      <tr>
        <td id="L455" class="blob-num js-line-number" data-line-number="455"></td>
        <td id="LC455" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>sheep<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>,</td>
      </tr>
      <tr>
        <td id="L456" class="blob-num js-line-number" data-line-number="456"></td>
        <td id="LC456" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span>measles<span class="pl-k">$</span><span class="pl-pds">/</span>i</span>,</td>
      </tr>
      <tr>
        <td id="L457" class="blob-num js-line-number" data-line-number="457"></td>
        <td id="LC457" class="blob-code blob-code-inner js-file-line"><span class="pl-sr">    <span class="pl-pds">/</span><span class="pl-c1">[<span class="pl-k">^</span>aeiou]</span>ese<span class="pl-k">$</span><span class="pl-pds">/</span>i</span> <span class="pl-c"><span class="pl-c">//</span> &quot;chinese&quot;, &quot;japanese&quot;</span></td>
      </tr>
      <tr>
        <td id="L458" class="blob-num js-line-number" data-line-number="458"></td>
        <td id="LC458" class="blob-code blob-code-inner js-file-line">  ].<span class="pl-c1">forEach</span>(<span class="pl-smi">pluralize</span>.<span class="pl-smi">addUncountableRule</span>);</td>
      </tr>
      <tr>
        <td id="L459" class="blob-num js-line-number" data-line-number="459"></td>
        <td id="LC459" class="blob-code blob-code-inner js-file-line">
</td>
      </tr>
      <tr>
        <td id="L460" class="blob-num js-line-number" data-line-number="460"></td>
        <td id="LC460" class="blob-code blob-code-inner js-file-line">  <span class="pl-k">return</span> pluralize;</td>
      </tr>
      <tr>
        <td id="L461" class="blob-num js-line-number" data-line-number="461"></td>
        <td id="LC461" class="blob-code blob-code-inner js-file-line">});</td>
      </tr>
</table>

  </div>

</div>

<button type="button" data-facebox="#jump-to-line" data-facebox-class="linejump" data-hotkey="l" class="d-none">Jump to Line</button>
<div id="jump-to-line" style="display:none">
  <!-- '"` --><!-- </textarea></xmp> --></option></form><form accept-charset="UTF-8" action="" class="js-jump-to-line-form" method="get"><div style="margin:0;padding:0;display:inline"><input name="utf8" type="hidden" value="&#x2713;" /></div>
    <input class="form-control linejump-input js-jump-to-line-field" type="text" placeholder="Jump to line&hellip;" aria-label="Jump to line" autofocus>
    <button type="submit" class="btn">Go</button>
</form></div>

  </div>
  <div class="modal-backdrop js-touch-events"></div>
</div>


    </div>
  </div>

    </div>

        <div class="container site-footer-container">
  <div class="site-footer" role="contentinfo">
    <ul class="site-footer-links float-right">
        <li><a href="https://github.com/contact" data-ga-click="Footer, go to contact, text:contact">Contact GitHub</a></li>
      <li><a href="https://developer.github.com" data-ga-click="Footer, go to api, text:api">API</a></li>
      <li><a href="https://training.github.com" data-ga-click="Footer, go to training, text:training">Training</a></li>
      <li><a href="https://shop.github.com" data-ga-click="Footer, go to shop, text:shop">Shop</a></li>
        <li><a href="https://github.com/blog" data-ga-click="Footer, go to blog, text:blog">Blog</a></li>
        <li><a href="https://github.com/about" data-ga-click="Footer, go to about, text:about">About</a></li>

    </ul>

    <a href="https://github.com" aria-label="Homepage" class="site-footer-mark" title="GitHub">
      <svg aria-hidden="true" class="octicon octicon-mark-github" height="24" version="1.1" viewBox="0 0 16 16" width="24"><path fill-rule="evenodd" d="M8 0C3.58 0 0 3.58 0 8c0 3.54 2.29 6.53 5.47 7.59.4.07.55-.17.55-.38 0-.19-.01-.82-.01-1.49-2.01.37-2.53-.49-2.69-.94-.09-.23-.48-.94-.82-1.13-.28-.15-.68-.52-.01-.53.63-.01 1.08.58 1.23.82.72 1.21 1.87.87 2.33.66.07-.52.28-.87.51-1.07-1.78-.2-3.64-.89-3.64-3.95 0-.87.31-1.59.82-2.15-.08-.2-.36-1.02.08-2.12 0 0 .67-.21 2.2.82.64-.18 1.32-.27 2-.27.68 0 1.36.09 2 .27 1.53-1.04 2.2-.82 2.2-.82.44 1.1.16 1.92.08 2.12.51.56.82 1.27.82 2.15 0 3.07-1.87 3.75-3.65 3.95.29.25.54.73.54 1.48 0 1.07-.01 1.93-.01 2.2 0 .21.15.46.55.38A8.013 8.013 0 0 0 16 8c0-4.42-3.58-8-8-8z"/></svg>
</a>
    <ul class="site-footer-links">
      <li>&copy; 2017 <span title="0.12199s from github-fe-b03c132.cp1-iad.github.net">GitHub</span>, Inc.</li>
        <li><a href="https://github.com/site/terms" data-ga-click="Footer, go to terms, text:terms">Terms</a></li>
        <li><a href="https://github.com/site/privacy" data-ga-click="Footer, go to privacy, text:privacy">Privacy</a></li>
        <li><a href="https://github.com/security" data-ga-click="Footer, go to security, text:security">Security</a></li>
        <li><a href="https://status.github.com/" data-ga-click="Footer, go to status, text:status">Status</a></li>
        <li><a href="https://help.github.com" data-ga-click="Footer, go to help, text:help">Help</a></li>
    </ul>
  </div>
</div>



    

    <div id="ajax-error-message" class="ajax-error-message flash flash-error">
      <svg aria-hidden="true" class="octicon octicon-alert" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8.865 1.52c-.18-.31-.51-.5-.87-.5s-.69.19-.87.5L.275 13.5c-.18.31-.18.69 0 1 .19.31.52.5.87.5h13.7c.36 0 .69-.19.86-.5.17-.31.18-.69.01-1L8.865 1.52zM8.995 13h-2v-2h2v2zm0-3h-2V6h2v4z"/></svg>
      <button type="button" class="flash-close js-flash-close js-ajax-error-dismiss" aria-label="Dismiss error">
        <svg aria-hidden="true" class="octicon octicon-x" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48z"/></svg>
      </button>
      You can't perform that action at this time.
    </div>


      
      <script crossorigin="anonymous" integrity="sha256-l96JcOm40vbROHPVCcxZsvNfQQZb1VyY69CSP4/m0eU=" src="https://assets-cdn.github.com/assets/frameworks-97de8970e9b8d2f6d13873d509cc59b2f35f41065bd55c98ebd0923f8fe6d1e5.js"></script>
      <script async="async" crossorigin="anonymous" integrity="sha256-E6d3qJZCMNQSt9GwF9Ew2I3z0ryAIwSfaJYG7ghxzVE=" src="https://assets-cdn.github.com/assets/github-13a777a8964230d412b7d1b017d130d88df3d2bc8023049f689606ee0871cd51.js"></script>
      
      
      
      
    <div class="js-stale-session-flash stale-session-flash flash flash-warn flash-banner d-none">
      <svg aria-hidden="true" class="octicon octicon-alert" height="16" version="1.1" viewBox="0 0 16 16" width="16"><path fill-rule="evenodd" d="M8.865 1.52c-.18-.31-.51-.5-.87-.5s-.69.19-.87.5L.275 13.5c-.18.31-.18.69 0 1 .19.31.52.5.87.5h13.7c.36 0 .69-.19.86-.5.17-.31.18-.69.01-1L8.865 1.52zM8.995 13h-2v-2h2v2zm0-3h-2V6h2v4z"/></svg>
      <span class="signed-in-tab-flash">You signed in with another tab or window. <a href="">Reload</a> to refresh your session.</span>
      <span class="signed-out-tab-flash">You signed out in another tab or window. <a href="">Reload</a> to refresh your session.</span>
    </div>
    <div class="facebox" id="facebox" style="display:none;">
  <div class="facebox-popup">
    <div class="facebox-content" role="dialog" aria-labelledby="facebox-header" aria-describedby="facebox-description">
    </div>
    <button type="button" class="facebox-close js-facebox-close" aria-label="Close modal">
      <svg aria-hidden="true" class="octicon octicon-x" height="16" version="1.1" viewBox="0 0 12 16" width="12"><path fill-rule="evenodd" d="M7.48 8l3.75 3.75-1.48 1.48L6 9.48l-3.75 3.75-1.48-1.48L4.52 8 .77 4.25l1.48-1.48L6 6.52l3.75-3.75 1.48 1.48z"/></svg>
    </button>
  </div>
</div>

  </body>
</html>

