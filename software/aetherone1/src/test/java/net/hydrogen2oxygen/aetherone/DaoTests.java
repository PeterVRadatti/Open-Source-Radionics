package net.hydrogen2oxygen.aetherone;

import net.hydrogen2oxygen.aetherone.peristence.dao.TargetRepository;
import net.hydrogen2oxygen.aetherone.peristence.jpa.Target;
import org.junit.Assert;
import org.junit.Before;
import org.junit.Test;
import org.junit.runner.RunWith;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.boot.test.context.SpringBootTest;
import org.springframework.test.annotation.Rollback;
import org.springframework.test.context.junit4.SpringRunner;
import org.springframework.test.context.transaction.TransactionConfiguration;
import org.springframework.transaction.annotation.Transactional;

import java.util.List;
import java.util.UUID;

@RunWith(SpringRunner.class)
@SpringBootTest(webEnvironment = SpringBootTest.WebEnvironment.RANDOM_PORT)
@Transactional
public class DaoTests {

    @Autowired
    private TargetRepository targetRepository;

    @Before
    public void init() {
        Assert.assertNotNull(targetRepository);
    }

    @Rollback(false)
    @Test
    public void testPersistence() {
        Target t1 = new Target();
        t1.setName("test");
        t1.setDescription("test target");
        t1.setSignature(UUID.randomUUID().toString());

        targetRepository.save(t1);

        List<Target> result = targetRepository.findByName("test");
        Assert.assertTrue("Nothing found after persistance, this is bad!", result.size() > 0);
        Assert.assertEquals("test",targetRepository.findByName("test").get(0).getName());
    }
}
