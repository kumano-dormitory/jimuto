class SolutionsController < ApplicationController
  before_action :set_solution, only: [:show, :edit, :update, :destroy]
  before_action :set_window, only: [:index, :new]

  # GET /solutions
  # GET /solutions.json
  def index
    @solutions = Solution.where(window: @window).sort_by { |solution| - solution.score }
  end

  # GET /solutions/1
  # GET /solutions/1.json
  def show
  end

  # GET /solutions/new
  def new
    if params[:copy_from].present? && Solution.find(params[:copy_from])&.user == current_user
      @solution = Solution.find(params[:copy_from])
    else
      @solution = Solution.new
    end
    @shifts = Shift.where(window: @window).group_by{|s| s.start.strftime("%Y-%m-%d")}
  end

  # GET /solutions/1/edit
  def edit
  end

  # POST /solutions
  # POST /solutions.json
  def create
    # params[:shifts]は、Shiftのid => Requestのid のハッシュ
    shift = Shift.find(params[:shifts].first.first.to_i)
    solution = current_user.solutions.create(window: shift.window)
    request_solutions = params[:shifts].map{|_, request_id| solution.request_solutions.build(request_id: request_id.to_i) }

    if RequestSolution.import request_solutions
      redirect_to controller: :solutions, action: 'index', notice: 'シフトの解決案を提出しました。', window_id: solution.window.id
    end
  end

  # PATCH/PUT /solutions/1
  # PATCH/PUT /solutions/1.json
  def update
    respond_to do |format|
      if @solution.update(solution_params)
        format.html { redirect_to @solution, notice: 'Solution was successfully updated.' }
        format.json { render :show, status: :ok, location: @solution }
      else
        format.html { render :edit }
        format.json { render json: @solution.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /solutions/1
  # DELETE /solutions/1.json
  def destroy
    @solution.destroy
    respond_to do |format|
      format.html { redirect_to solutions_url, notice: 'Solution was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_solution
      @solution = Solution.find(params[:id])
    end
    
    def set_window
      @window = Window.find(params[:window_id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def solution_params
      params.fetch(:solution, {})
    end
end
