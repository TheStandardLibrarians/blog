# app.rb
require "sinatra"
require "sinatra/activerecord"

# set :database, "sqlite3:///blog.db"
#db = URI.parse('postgres://user:pass@localhost/dbname')
set :database, "postgres:///blog.db"

ActiveRecord::Base.establish_connection(
  :adapter  => db.scheme == 'postgres' ? 'postgresql' : db.scheme,
  :host     => db.host,
  :username => db.user,
  :password => db.password,
  :database => db.path[1..-1],
  :encoding => 'utf8'blog.db
)

class Post < ActiveRecord::Base
end

helpers do
  # If @title is assigned, add it to the page's title
  def title
    if @title
      "#{@title} -- The Standard Librarians Blog"
    else
      "My Blog"
    end
  end

  # Format the Ruby Time object returned from a post's created_at method
  # into a string that looks like this: July 01 2014
  def pretty_date(time)
   time.strftime("%b %d %Y")
  end

end

get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

# Get all of our routes
get "/" do
  @posts = Post.order("created_at DESC")
  erb :"posts/index"
end

# Get the New Post form
get "/posts/new" do
  @title = "New Post"
  @post = Post.new
  erb :"posts/new"
end

# The New Post form sends a POST request (storing data) here
# where we try to create the post it sent in its params hash.
# If successful, redirect to that post. Otherwise, render the "posts/new"
# template where the @post object will have the incomplete data that the
# user can modify and re-submit.
post "/posts" do
  @post = Post.new(params[:post])
  if @post.save
    redirect "posts/#{@post.id}"
  else
    erb :"posts/new"
  end
end

# Get the individual page of the post with this ID
get "/posts/:id" do
  @post = Post.find(params[:id])
  @title = @post.title
  erb :"/posts/show"
end

# Get the Edit Post form of the post with this ID
get "/posts/:id/edit" do
  @post = Post.find(params[:id])
  @title = "Edit Form"
  erb :"posts/edit"
end

# The Edit Post form sends a PUT request (modifying data) here.
# If the post is updated successfully, redirect to it; otherwise,
# render the edit form again with the failed @post object still in memory
# so they can retry.
put "/posts/:id" do
  @post = Post.find(params[:id])
  if @post.update_attributes(params[:post])
    redirect "/posts/#{@post.id}"
  else
    erb :"posts/edit"
  end
end

# Deletes the post with this ID and redirects to homepage
delete "/posts/:id" do
  @post = Post.find(params[:id]).destroy
  redirect "/"
end

# Our Contributors page
get "/contributors" do
  @title = "Contributors"
  erb :"pages/contributors"
end

# References page
get "/reference" do
  @title = "Reference"
  erb :"pages/reference"
end
