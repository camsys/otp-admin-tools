class ConfigsController < AdminController
  
  before_action :load_configs, only: [:index, :update]
  
  PERMITTED_CONFIGS = [
    :otp_url,
    :otp_api_key,
    :otp2_url,
    :otp2_api_key,
    :atis_app_id,
    :atis_url,
    :atis_otp_mapping
  ].freeze

  def index
  end
  
  def update
    configs = configs_params.to_h.map do |k,v|
      [ @configs.find_or_create_by(key: k).id, { value: format_config_value(k, v) } ]
    end.to_h
        
    # Update all relevant configs at once, as a batch
    @errors = Config.update(configs.keys, configs.values)
                    .map(&:errors)
                    .select(&:present?)
    flash[:danger] = @errors.flat_map(&:full_messages)
                            .to_sentence unless @errors.empty?

    redirect_to configs_path 

  end

  def update_atis_otp_mapping
    atis_otp_mapping = params[:config][:atis_otp_mapping] if params[:config]
    if !atis_otp_mapping.nil?
      Config.update_atis_otp_mapping atis_otp_mapping
    end
    redirect_to configs_path
  end
  
  def configs_params
    params.require(:config).permit(PERMITTED_CONFIGS)
  end
  
  def load_configs
    @configs = Config.where(key: PERMITTED_CONFIGS.flat_map {|k| k.try(:keys) || k })
  end
  
  # This helper method allows pre-formatting of values before updating the
  # config itself. This is useful if a particular config requires a special 
  # format, for example the daily_scheduled_tasks must be an array of symbols.
  def format_config_value(key, value)
    case key.to_sym
    when :daily_scheduled_tasks
      return value.select(&:present?).map(&:to_sym)
    else
      return value
    end
  end

end
