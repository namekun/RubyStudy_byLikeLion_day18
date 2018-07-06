# 20180705 JS with LikeLion

### 좋아요 버튼 + 개수 넣고 변화하는것

- ParseInt
  - https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Global_Objects/parseInt 참조
- Javascript string interpolation
  - https://developer.mozilla.org/ko/docs/Web/JavaScript/Reference/Template_literals 참조

*show.html.erb*

```html
<h1><%=@movie.title%></h1>
<hr>
<p><%=@movie.description%></p>
<%= link_to 'Edit', edit_movie_path(@movie) %> |
<%= link_to 'Back', movies_path %>
<hr>
<% if(@like.nil?)%>
    <button class="btn btn-info like">좋아요(<span class='like-count'><%=@movie.likes.count%></span>)</button>
<%else%>
    <button class="btn btn-warning text-white like">좋아요 취소(<span class='like-count'><%=@movie.likes.count%></span>)</button>
<%end%>
<script>
    $(document).ready(function(){
        $('.like').on('click',function(){
            console.log("like!!!");
            $.ajax({
                url:'/likes/<%=@movie.id%>'
            });
        });
    });
</script>
```

*movie_controller.rb*

```ruby
class MoviesController < ApplicationController
  before_action :authenticate_user!, except:[:index,:show]
  before_action :js_authenticate_user!, except:[:index,:show]
  before_action :set_movie, only: [:show, :edit, :update, :destroy]
  

  # GET /movies
  # GET /movies.json
  def index
    @movies = Movie.all
  end

  # GET /movies/1
  # GET /movies/1.json
  def show
      @like = Like.where(user_id: current_user.id, movie_id: params[:id]).first if user_signed_in?
  end

  # GET /movies/new
  def new
    @movie = Movie.new
  end

  # GET /movies/1/edit
  def edit
  end

  # POST /movies
  # POST /movies.json
  def create
    @movie = Movie.new(movie_params)
    @movie.user_id = current_user.id
    respond_to do |format|
      if @movie.save
        format.html { redirect_to @movie, notice: 'Movie was successfully created.' }
        format.json { render :show, status: :created, location: @movie }
      else
        format.html { render :new }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /movies/1
  # PATCH/PUT /movies/1.json
  def update
    respond_to do |format|
      if @movie.update(movie_params)
        format.html { redirect_to @movie, notice: 'Movie was successfully updated.' }
        format.json { render :show, status: :ok, location: @movie }
      else
        format.html { render :edit }
        format.json { render json: @movie.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /movies/1
  # DELETE /movies/1.json
  def destroy
    @movie.destroy
    respond_to do |format|
      format.html { redirect_to movies_url, notice: 'Movie was successfully destroyed.' }
      format.json { head :no_content }
    end
  end
 
  def like_movie
    #현재 유저와 params에 담긴 movie간의 
    #whgdkdy rhksrPfmf tjfwjdgksek.
    
    #만약 현재 로그인한 유저가 이미 좋아요를 눌렀을 경우
    #해당 like 인스턴스 삭제
    #새로 누른 경우
    #좋아요 관계 설정
    @like = Like.where(user_id:current_user.id,movie_id: params[:movie_id]).first
    puts @like.nil?
    if @like.nil?
      @like = Like.create(user_id: current_user.id,movie_id: params[:movie_id])
    else
      @like.destroy
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_movie
      @movie = Movie.find(params[:id])
     
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def movie_params
      params.require(:movie).permit(:title,:genre,:director,:actor,:description, :image_path)
    end
    
    
end
```

*like_movie.js.erb*

```erb
var like_count = parseInt($('.like-count').text());

if(<%=@like.frozen?%>){
    <!--frozen 이 true 좋아요 눌린인간이 취소함 다시 좋아요 표시 되게끔함-->
    like_count = like_count -1
    $('.like').html(`좋아요(<span class='like-count'>${like_count}</span>)`).toggleClass("btn-warning btn-info text-white");
   
     
}else{
    like_count = like_count +1
     $('.like').html(`좋아요 취소(<span class="like-count">${like_count}</span>)`).toggleClass("btn-warning btn-info text-white");
    
     
}
//좋아요가 취소된 경우
// 좋아요 취소버튼 -> 좋아요 버튼

//좋아요가 새로 눌린 경우
//좋아요 버튼 -> 좋아요 취소버튼으로 
```



### ajax

- ajax를 이용하면 각종 single page applicaion 구성이 가능해진다. 한개의 페이지에서 이동 없이 지속적으로 서버와 통신하며 사용자의 입력사항을 저장하고 수정할 수 있다. (하지만 모든 기능들을 ajax 코드로 구현하는 끔찍한 일을 막기 위해서 프론트앤드 자바스크립트 프레임워크/라이브러리, 예를들어 angular, vue, react 등과 같은 기술이 나오고 있다.) ajax와 javascript/jquery에 익숙해지기 위해 댓글을 구현해보고자 한다.



*db/migrate/create_comments.rb*

```ruby
class CreateComments < ActiveRecord::Migration[5.0]
  def change
    create_table :comments do |t|
      t.integer         :user_id
      t.integer         :movie_id
      t.string          :contents

      t.timestamps
    end
  end
end
```

- 댓글을 등록하기 위한 모델을 만들어준다. 생각해보면 이 comment 모델도 조인테이블로 활용할 수 있다. 하지만 실제로 M:N의 관계를 만들어주는 것은 지난 시간에 구현한 Like 모델이므로 추가적인 설정은 하지 않는다.

*app/models/comment.rb*

```ruby
class Comment < ApplicationRecord
    belongs_to :user
    belongs_to :movie
end
```

*app/models/movie.rb*

```ruby
...
    has_many :comments
...
```

*app/models/user.rb*

```ruby
...
    has_many :comments
...
```




  #### create_comment

  - 댓글 등록이  동작하는 과정은 다음과 같다.

  >- 댓글을 입력받을 폼을 작성
  >- form(요소)이 제출(이벤트)될 때(이벤트 리스너)
  >- form에 input(요소) 안에 있는 내용물(메소드)을 받아서
  >- ajax 요청으로 서버에 '/create/comment'로 요청을 보낸다.
  >- 보낼 때에는 내용물, 현재 보고있는 movie의 id 값도 같이 보낸다.
  >- 서버에서 저장하고, response 보내줄 js.erb 파일을 작성한다.
  >- js.erb 파일에서는 댓글이 표시될 영역에 등록된 댓글의 내용을 추가해준다.

  - 레일즈 프로젝트에서 ajax를 구현하기 위해서는 다음과 같은 순서를 갖는다.

  > 1. ajax 코드를 작성한다. (`$.ajax({})`)
  > 2. url 을 지정한다.
  > 3. 해당 url을 *config/routes.rb*에서 controller#action을 지정한다.
  > 4. controller#action을 자성한다.
  > 5. *app/views/controller_name*에 action명과 일치하는 `js.erb` 파일을 작성한다.

  - 항상  잘 기억해두고 각 순서에 맞춰 구현하도록한다.

  *app/views/show.html.erb*

  ```erb
  <form class="text-right comment">
      <input class="form-control comment-contents">
      <input type="submit" value="댓글쓰기" class="btn btn-success">
  </form>
  ...
  <script>
      $(document).on('ready', function() {
          $('.comment').on('submit', function(e) {
              e.preventDefault();
              var comm = $('.comment-contents').val();
              console.log(comm);
  
              $.ajax({
                  url: "/movies/<%= @movie.id %>/comments",
                  method: "POST",
                  data: {
                      contents: comm
                  }
              })
          });
      })
  </script>
  ```
 ```

  *config/routes.rb*

  ```ruby
  ...
    resources :movies do
      member do
        post '/comments' => 'movies#create_comment'
      end
    end
  ...
 ```

  - nested routing을 통해 조금 더 복잡한 라우팅을 쉽게 지정할 수 있다. 자세한 정보는 [이곳](http://guides.rubyonrails.org/routing.html#nested-resources)을 참조한다.

  > `member` : `/movies/:(movie_)id/`를 기본으로 추가적인 uri를 설정한다
  >
  > `collection` : `/movies/`를 기본으로 추가적인 uri를 설정한다.

  *app/controllers/movies_controller.rb*


 ```ruby
  ...  
    def create_comment
      # @movie = Movie.find(params[:id]) => filter에 create_comment를 추가한다.
      @comment = Comment.create(user_id: current_user.id, movie_id: @movie.id, contents: params[:contents])
    end
  ..
 ```


*app/views/movies/create_comment.js.erb*

  ```erb
  $('.comment-list').prepend(`
  <li class="comment-<%= @comment.id %> list-group-item d-flex justify-content-between">
      <span class="comment-detail-<%= @comment.id %>"><%= @comment.contents %></span>
      <div>
          <button data-id="<%= @comment.id %>" class="btn btn-warning text-white edit-comment">수정</button>
          <button data-id="<%= @comment.id %>" class="btn btn-danger destroy-comment">삭제</button>
      </div>
  </li>`);
  $('.comment-contents').val('');
  alert("댓글 등록이 완료됐습니다.");
  ```

  - 모든 과정을 차근히 진행하면 어렵지 않게 구현할 수 있다.

  

  #### destroy_comment

  - 등록되어 있는 댓글을 삭제하는 과정은 다음과 같다.

  > - 댓글에 있는 삭제 버튼(요소)을 누르면(이벤트 리스너)
  > - 해당 댓글이 눈에 안보이게 되고(이벤트 핸들러),
  > - 실제 DB에서도 삭제가 된다(ajax).

  - `create_comment`에서도 마찬가지 이지만, 실제로 이벤트 핸들러의 요소 추가 및 삭제는 ajax 요청에 대한 응답으로 돌아오는 js 코드에서 구현된다.

  *app/views/movies/show.html.erb*

  ```erb
  ...
  	$(document).on('click', '.destroy-comment', function() {
          console.log("destroyed!!!");
          var comment_id = $(this).attr('data-id');
          // $(this).data('id');
          console.log(comment_id);
          $.ajax({
              url: "/movies/comments/" + comment_id,
              method: "delete"
          })
      });
  ...
  ```

  - 버튼 클릭의 이벤트 리스너가 기존과 다른 형태로 구현되어 있는 것을 알 수 있다.  해당 형태는 이벤트 핸들러르 등록하는 jQuery `.on`에서 앞서 선택된 요소의 자식중에서 두번째 매개변수에 있는 요소를 찾게된다. 우리가 `create_comment`에서 구현한 댓글 추가는 동적으로 추가한 요소이기 때문에 기존의 방식으로는 요소를 찾을 수 없고 이 방식을 통해 요소를 찾아야만 동적으로 추가된 요소를 찾을 수 있다. 자세한 정보는 [이곳](http://api.jquery.com/on/)을 참조한다.

  *config/routes.rb*

  ```ruby
  ...
    resources :movies do
      collection do
        delete '/comments/:comment_id' => 'movies#destroy_comment'
      end
    end
  ...
  ```

  *app/controllers/movies_controller.rb*

  ```ruby
  ...
    def destroy_comment
      @comment = Comment.find(params[:comment_id]).destroy
    end
  ...
  ```

  *app/views/movies/destroy_comment.js.erb*

  ```erb
  alert("댓글이 삭제 되었습니다.");
  $('.comment-<%= @comment.id %>').remove();
  ```

  - 삭제되는 요소를 정확히 찾기 위해서 삭제될 요소의 class에 id가 추가된 부분을 부여하여 삭제될 수 있도록 하였다. 이벤트 핸들러 내에 해당 코드가 있을 경우 `this`로 참조가 가능하지만 파일을 분리한 현재의 상태에서는 `this`의 참조값이  없는 상태이다.

  

  #### edit_comment & update_comment

  - 댓글을 수정하는 방식은 다양하지만 일단은 *어렵다..* 단계로 구분해도 많은 단계가 있기 때문이다.

  > - 수정 버튼(요소)을 클릭하면(이벤트 리스너)
  >
  > - 댓글이 있던 부분(요소)이 입력창(`.html()`)으로 바뀌면서 원래 있던 댓글의 내용(`.text()`)이 입력창에 들어간다.
  >
  > - 수정버튼은 확인 버튼으로 바뀐다.
  >
  >   ------
  >
  >   
  >
  > - 내용 수정 후 확인 버튼(요소)을 클릭하면(이벤트 리스너)
  >
  > - 입력창에 있던 내용물(`.val()`)이 댓글의 원래 형태로 바뀌고 
  >
  > - 확인버튼은 다시 수정버튼으로 바뀐다.
  >
  > - 입력창에 있던 내용물을 ajax로 서버에 요청을 보낸다.
  >
  > - 서버에서는 해당 댓글을 찾아 내용을 업데이트 한다.

  - 댓글을 수정할 때에는 두가지  과정을 거쳐야 하기 때문에 굉장히 단계가 많아 보인다. 또한 기존에는 추가/삭제만 하면 됐던 부분들에서 *수정*을 해야하기 때문에 구현에 어려움을 겪을 수 있다.

  *app/views/movies/show.html.erb*

  ```erb
  ...
  $(document).on('click', '.edit-comment', function() {
          // console.log($(this).parent().parent().find('.comment-detail');
          // console.log($(this).parent().siblings());
          var comment_id = $(this).data('id');
          var edit_comment = $(`.comment-detail-${comment_id}`);
          var contents = edit_comment.text().trim();
          edit_comment.html(`
          <input type="text" value="${contents}" class="form-control edit-comment-${comment_id}">`);
          $(this).text("확인").removeClass("edit-comment btn-warning").addClass("update-comment btn-dark");
  });
  ...
  ```

  - 현재 이벤트가 발생한, 즉 수정할 요소가 있는 곳을 찾기 위해 각 부분에 data-id와 id를 부여했다. 변수명과 클래스명을 헷갈리지 않도록 주의한다.
  - 여기까지 구현하면 수정 버튼을 눌렀을 때 댓글 출력부분이 form으로 바뀌고 입력할 수 있게 바뀐다.

  

  *app/views/movies/show.html.erb*

  ```erb
  $(document).on('click', '.update-comment', function() {
          var comment_id = $(this).data('id');
          var comment_form = $(`.edit-comment-${comment_id}`);
          $.ajax({
              url: "/movies/comments/" + comment_id,
              method: "patch",
              data: {
                  contents: comment_form.val()
              }
          })
  });
  ```

  *config/routes.rb*

  ```erb
  ...
    resources :movies do
      collection do
        patch '/comments/:comment_id' => 'movies#update_comment'
      end
    end
  ...
  ```

  *app/controllers/movies_controller.rb*

  ```ruby
  ...
    def update_comment
      @comment = Comment.find(params[:comment_id])
      @comment.update(contents: params[:contents])
    end
  ...
  ```

  *app/views/movies/update_comment.js.erb*

  ```erb
  alert("수정완료");
  var edit_comment = $('.comment-detail-<%= @comment.id %>');
  edit_comment.html('<%= @comment.contents %>');
  $('.update-comment').text("수정").removeClass("update-comment btn-dark").addClass("edit-comment btn-warning");
  ```

  - 복잡한 코드가 일부 있지만 주어진 상황을 세분화 하여 진행하다보면 성공적으로 코드를 구현할 수 있다.






  #### 0705 과제

  * 내용수정 후 확인버튼을 클릭하면
  * 입력창에 있던 내용물이 댓글의 원래 형태로 바뀌고, 확인버튼은 다시 수정버튼으로 바뀐다.
  * 수정버튼을 누르면, 전체 문서중에서 `update-comment`클래스를 가진 버튼이 있는 경우에, 더이상 진행하지 않고 이벤트 핸들러를 끝낸다. `return false;`



### comment model 만들기

* column: user_id, movie_id, contents
* association: 
  * movie(1) - comment(N)
  * user(1) - comment(N)
* 다하면 ajax코드로 
  * url("/movies/:movie_id/comments", method:post)



#### 0706 ToDo

* pagination(kaminari)
* hashtag(제목 중복, id 중복)
