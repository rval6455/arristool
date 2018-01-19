class ArrisHeadendsController < ApplicationController
  # GET /arris_headends
  # GET /arris_headends.json
  def index
    @arris_headends = ArrisHeadend.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render json: @arris_headends }
    end
  end

  # GET /arris_headends/1
  # GET /arris_headends/1.json
  def show
    @arris_headend = ArrisHeadend.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render json: @arris_headend }
    end
  end

  # GET /arris_headends/new
  # GET /arris_headends/new.json
  def new
    @arris_headend = ArrisHeadend.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render json: @arris_headend }
    end
  end

  # GET /arris_headends/1/edit
  def edit
    @arris_headend = ArrisHeadend.find(params[:id])
  end

  # POST /arris_headends
  # POST /arris_headends.json
  def create
    @arris_headend = ArrisHeadend.new(arris_headend_params)

    respond_to do |format|
      if @arris_headend.save
        format.html { redirect_to @arris_headend, notice: 'Arris headend was successfully created.' }
        format.json { render json: @arris_headend, status: :created, location: @arris_headend }
      else
        format.html { render action: "new" }
        format.json { render json: @arris_headend.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /arris_headends/1
  # PATCH/PUT /arris_headends/1.json
  def update
    @arris_headend = ArrisHeadend.find(params[:id])

    respond_to do |format|
      if @arris_headend.update_attributes(arris_headend_params)
        format.html { redirect_to @arris_headend, notice: 'Arris headend was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render action: "edit" }
        format.json { render json: @arris_headend.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /arris_headends/1
  # DELETE /arris_headends/1.json
  def destroy
    @arris_headend = ArrisHeadend.find(params[:id])
    @arris_headend.destroy

    respond_to do |format|
      format.html { redirect_to arris_headends_url }
      format.json { head :no_content }
    end
  end

  private

    # Use this method to whitelist the permissible parameters. Example:
    # params.require(:person).permit(:name, :age)
    # Also, you can specialize this method with per-user checking of permissible attributes.
    def arris_headend_params
      params.require(:arris_headend).permit(:downstream_freq, :host, :name, :polarity)
    end
end
