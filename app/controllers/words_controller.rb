class WordsController < ApplicationController
  def index
    @words = Word.all
  end
  
  def comparison
    
    # 入力された文字列とrandom()で生成されたidが一致するか
    if Word.find_by(id: params[:random], japanese: params[:answer])
      # 正解
      flash[:correction] = "正解"
    else
      # 不正解
      flash[:correction] = "不正解"
    end
    
    redirect_to(root_url)
  end
    
  # 解答一覧
  def answer
    @words = Word.all
  end
  

end
