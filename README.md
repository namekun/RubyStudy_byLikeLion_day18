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

- 댓글(ajax) 입력 + 삭제 + 수정

  * 댓글 입력시 글자제한 (front + back)
  * 댓글을 입력받을 폼을 작성
  * form(요소)이 제출(이벤트)될 때(이벤트 리스너)
  * form에 input(요소) 안에 있는 내용물(메소드)을 받아서
  * ajax요청으로 서버에 '/create/comment'로 요청을 보낸다.
  * 보낼 때에는 내용물, 현재 보고있는 movie의 id값도 같이 보낸다.
  * 서버에서 저장하고, response 보내줄 js.erb 파일을 작성한다.
  * js.erb 파일에서는 댓글이 표시될 영역에 등록된 댓글의 내용을 추가해준다.

  

  * 댓글에 있는 삭제버튼(요소)을 누르면(이벤트 리스너)

  * 해당 댓글이 눈에 안보이게 되고, (이벤트 핸들러)

  * 실제 DB에서도 삭제가 된다(ajax)

    

  * 수정버튼을 클릭하면

  * 댓글이 있던 부분이 입력창으로 바뀌면서 원래 있던 댓글의 내용이 입력창에 들어간다.

  * 수정버튼은 확인 버튼으로 바뀐다.

  

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
