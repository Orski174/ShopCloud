'use strict';

module.exports = {
  async up(queryInterface) {
    const [[{ count }]] = await queryInterface.sequelize.query(
      "SELECT COUNT(*) as count FROM admin_users"
    );
    if (parseInt(count) > 0) return;

    await queryInterface.bulkInsert('admin_users', [
      {
        id: 'c3d4e5f6-0003-0003-0003-000000000001',
        email: 'admin@shopcloud.com',
        name: 'Shop Admin',
        // bcrypt hash of 'Admin1234!'
        password_hash: '$2a$10$iU5sQlb1SJCGctAVSKdjx.KNTbyJbpYHGOJGiijIpBTZtpEI.yuLO',
        role: 'admin',
        created_at: new Date(),
        updated_at: new Date(),
      },
    ]);
  },

  async down(queryInterface) {
    await queryInterface.bulkDelete('admin_users', null, {});
  },
};
