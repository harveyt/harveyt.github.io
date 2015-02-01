---
layout: post
title: "Free Blog Comments"
date: 2015-01-31T17:10:28-08:00
---

Purpose Of This Tutorial
=========================

* Set up a free blog commenting system.
  * We'll be using [Disqus] since it's free and easy to set up.
  * There are many alternatives, I picked the easiest and most popular.
  * See previous tutorial [Setting Up A Free Blog]({% post_url 2014-12-31-setting-up-a-free-blog %}) on how to set up a blog like this.

Step 1: Create An Account at Disqus
===================================

* Go to [Disqus] and get an account.
* Select "Add A New Site":
  * "Site name" - whatever your site name is.
  * "Choose your unique Disqus URL" - a unique lowercase name.
    * This will be used in some Jekyll files to link to your blog comments at Disqus.
    * It'll default to something reasonable.
  * "Category" - whatever makes the most sense.

Step 2: Get The Disqus Comments Snippet
=======================================

Next you need the HTML magic from [Disqus] to include in any pages that has comments.

* Get the correct version from "Settings -> Install -> Universal Code".
* Copy and paste the HTML text in the file `_includes/comments.html` in your Git repository for
  your website.
* We'll allow pages to turn comments on and off using Jekyll's front matter:
  * Add `{% raw %}{% if page.comments %}{% endraw %}` at the start of the file.
  * Add `{% raw %}{% endif %}{% endraw %}` at the end of the file.
* Example below, valid as of 31 Jan 2015. 
  * **IMPORTANT** The `my-disqus-id` in the snippet below should be modified to your unique [Disqus] URL. The value shown by Disqus will already have the correct value.

```html
{% if page.comments %}
<div id="disqus_thread"></div>
    <script type="text/javascript">
        /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
        var disqus_shortname = 'my-disqus-id'; // required: replace example with your forum shortname

        /* * * DON'T EDIT BELOW THIS LINE * * */
        (function() {
            var dsq = document.createElement('script'); dsq.type = 'text/javascript'; dsq.async = true;
            dsq.src = '//' + disqus_shortname + '.disqus.com/embed.js';
            (document.getElementsByTagName('head')[0] || document.getElementsByTagName('body')[0]).appendChild(dsq);
        })();
    </script>
    <noscript>Please enable JavaScript to view the <a href="https://disqus.com/?ref_noscript">comments powered by Disqus.</a></noscript>
{% endif %}
```

Step 3: Add The Comments To The Default Layout
==============================================

* Edit `_layouts/default.html`
* Add `{% raw %}{% include comments.html %}{% endraw %}` where you want comments to appear in each post.
* A good place is just after `{% raw %}{{ content }}{% endraw %}`, so it will read something like this:

```html
...
    <div class="page-content">
      <div class="wrapper">
        {{ content }}
        {% include comments.html %}
      </div>
    </div>
...
```

Step 4: Set The Post Template To Include Comments
=================================================

To make any future posts include comments always you should modify the template:

* Edit `_templates/post`
* Add `comments: true` before the second `---`.
* Example:

```yaml
---
layout: {{ layout }}
title: {{ title }}
comments: true
---
```

Step 5: Ensure Previous Post Include Comments
=============================================

If you have already made previous posts, you should remember to enable comments there:

* Edit each `_posts/NNNN-NN-NN-title.markdown`
* Add `comments: true` as described previously

Step 6: Build and Preview Locally
=================================

To make sure everything is working:

```console
$ jekyll build
$ jekyll serve
```

You should then be able to preview your site at <http://localhost:4000>.

Step 7: Deploy
==============

Once everything is fine you should commit your local changes to the site source:

```console
$ git commit -a -m 'Added Disqus comments.'
$ git push
```

Then you can deploy the site live:

```console
$ octopress deploy
```

You may wish to post a test comment at this point.

Step 8: Optional - Add Comment Counts to Index
==============================================

If you want to show number of comments in the index page, Disqus supports this.

* You need the HTML magic from [Disqus] to include in your `index.html`.
* Get the correct version from "Settings -> Install -> Universal
  Code", under the second "How to display comment count".
* Copy and paste the HTML text in the file
  `_includes/comment_counts.html` in your Git repository for your
  website.

* Example below, valid as of 31 Jan 2015. 
  * **IMPORTANT** The `my-disqus-id` in the snippet below should be modified to your unique [Disqus] URL. The value shown by Disqus will already have the correct value.

```html
<script type="text/javascript">
    /* * * CONFIGURATION VARIABLES: EDIT BEFORE PASTING INTO YOUR WEBPAGE * * */
    var disqus_shortname = 'my-disqus-id; // required: replace example with your forum shortname

    /* * * DON'T EDIT BELOW THIS LINE * * */
    (function () {
        var s = document.createElement('script'); s.async = true;
        s.type = 'text/javascript';
        s.src = '//' + disqus_shortname + '.disqus.com/count.js';
        (document.getElementsByTagName('HEAD')[0] || document.getElementsByTagName('BODY')[0]).appendChild(s);
    }());
</script>
```

* Next modify your `index.html` file to include a new link which will
  have the comment count as the link name.
* Example below has the comment after the post's title link:

```html
...
      <li>
        <span class="post-meta">{{ post.date | date: "%b %-d, %Y" }}</span>
 
        <a class="post-link" href="{{ post.url | prepend: site.baseurl }}">{{ post.title }}</a>

        <span class="post-meta">	
          <a href="{{ post.url | prepend: site.baseurl }}#disqus_thread">0 Comments</a>
        </span>
      </li>
...
```

* Build, Preview, Submit, Deploy as usual.

[disqus]: www.disqus.com
