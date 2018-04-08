package net.hydrogen2oxygen.aetherone.configuration;

import net.hydrogen2oxygen.aetherone.peristence.jpa.Case;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Rate;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Session;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Target;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.data.rest.core.config.RepositoryRestConfiguration;
import org.springframework.data.rest.webmvc.config.RepositoryRestConfigurer;
import org.springframework.data.rest.webmvc.config.RepositoryRestConfigurerAdapter;
import org.springframework.http.MediaType;

@Configuration
class CustomRestMvcConfiguration {

    @Bean
    public RepositoryRestConfigurer repositoryRestConfigurer() {

        return new RepositoryRestConfigurerAdapter() {

            @Override
            public void configureRepositoryRestConfiguration(RepositoryRestConfiguration config) {
                config.setDefaultMediaType(MediaType.APPLICATION_JSON);
                config.exposeIdsFor(Case.class, Session.class, Target.class, Rate.class);
            }
        };
    }
}
