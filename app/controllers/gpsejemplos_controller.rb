class GpsejemplosController < ApplicationController
  # GET /gpsejemplos
  # GET /gpsejemplos.json
  def index
    @usuarios = Usuario.all
    @usuarios_json = @usuarios.to_json
  end

  # GET /gpsejemplos/1
  # GET /gpsejemplos/1.json
  def show

  end

  # GET /gpsejemplos/new
  # GET /gpsejemplos/new.json
  def new

  end

  def edit
    @nombre = Usuario.find(params[:id]).nombre
    @gpsejemplo=Gpsejemplo.where(idUsuario: params[:id])
    @gpsejemplo_json=@gpsejemplo.to_json
  end

  def create
    @usuario = Usuario.new(usuario_params)
    ruta = params[:ruta]
    @usuario.save
    id=@usuario.id
    if(!ruta.eql?(nil))
      arreglo=JSON.parse(ruta)
      for i in 0..arreglo["route"].length-1
        @gpsejemplo=Gpsejemplo.new(:latitude => arreglo["route"][i]["latitude"], :longitude => arreglo["route"][i]["longitude"], :timestamp => arreglo["route"][i]["timestamp"].to_s, :idUsuario => id)
        @gpsejemplo.save
      end
    end
    redirect_to gpsejemplos_path, notice: 'El usuario con su ruta fue agregado satisfactoriamente.'
  end



  def rutas
    ids=params[:usua]
    @usuarios=[]
    @pois=[]
    @pois_json=[]
    @coincidencia=[]
    aux=[]
    if(!ids.eql?(nil))
      @usuarios=Usuario.find(ids)
      @pois=Gpsejemplo.where(idUsuario: ids)
      @pois=@pois.order("timestamp")
      radio=params[:radio]
      tiempo=params[:tiempo]
      for i in 0..@pois.length-1
        for j in i..@pois.length-1
          if(!(@pois[i].idUsuario.eql?(@pois[j].idUsuario)))
            dist=distancia(@pois[i].latitude,@pois[i].longitude,@pois[j].latitude,@pois[j].longitude)
            aux=[]
            if(dist<=radio.to_f)
              time=(@pois[i].timestamp.to_f-@pois[j].timestamp.to_f)/1000
              if(time<0)
                time=time*-1
              end
              if(time<=tiempo.to_f)
                aux<<@pois[i]
                aux<<@pois[j]
                @coincidencia<<aux
              end
            end
          end
        end
      end
      #@coincidencia.uniq!
      @pois_json=@pois.to_json
    end
  end
  def distancia(lat1,long1,lat2,long2)
    r= 6378.137
    dLat=(lat1-lat2)*Math::PI/180
    dLong=(long1-long2)*Math::PI/180
    a = Math.sin(dLat/2) * Math.sin(dLat/2) + Math.cos((lat2)*Math::PI/180) * Math.cos((lat1)*Math::PI/180) * Math.sin(dLong/2) * Math.sin(dLong/2)
    c = 2 * Math.atan2(Math.sqrt(a), Math.sqrt(1-a))
    d = r * c * 1000
    return d
  end

  def update
    @usuario = Usuario.find(params[:id])

    if @usuario.update_attributes(params[:usuario])
      # redirect the user to index
      redirect_to gpsejemplos_path, notice: 'Location was successfully updated.'
    else
      # redirect the user to the edit method
      render action: 'edit'
    end
  end

  def destroy
    @usuario = Usuario.find(params[:id])
    @gpsejemplo=Gpsejemplo.where(idUsuario: params[:id])
    @gpsejemplo.each do |ejem|
      ejem.destroy
    end
    @usuario.destroy
    redirect_to gpsejemplos_path, notice: 'Usuario was successfully deleted.'
  end

  def usuario_params
    params.require(:usuario).permit(:nombre)
  end
end
